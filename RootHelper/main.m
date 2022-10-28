#import <stdio.h>
@import Foundation;
#import "uicache.h"
#import <sys/stat.h>
#import <dlfcn.h>
#import <spawn.h>
#import <objc/runtime.h>
#import "TSUtil.h"
#import <sys/utsname.h>

#import <SpringBoardServices/SpringBoardServices.h>
#import <Security/Security.h>

typedef CF_OPTIONS(uint32_t, SecCSFlags) {
	kSecCSDefaultFlags = 0
};
#define kSecCSRequirementInformation 1 << 2
extern CFStringRef kSecCodeInfoEntitlementsDict;

typedef struct __SecCode const *SecStaticCodeRef;
OSStatus SecStaticCodeCreateWithPathAndAttributes(CFURLRef path, SecCSFlags flags, CFDictionaryRef attributes, SecStaticCodeRef *staticCode);
OSStatus SecCodeCopySigningInformation(SecStaticCodeRef code, SecCSFlags flags, CFDictionaryRef *information);

NSDictionary* dumpEntitlements(SecStaticCodeRef codeRef)
{
	if(codeRef == NULL)
	{
		NSLog(@"[dumpEntitlements] attempting to dump entitlements without a StaticCodeRef");
		return nil;
	}
	
	CFDictionaryRef signingInfo = NULL;
	OSStatus result;
	
	result = SecCodeCopySigningInformation(codeRef, kSecCSRequirementInformation, &signingInfo);
	
	if(result != errSecSuccess)
	{
		NSLog(@"[dumpEntitlements] failed to copy signing info from static code");
		return nil;
	}
	
	NSDictionary *entitlementsNSDict = nil;
	
	CFDictionaryRef entitlements = CFDictionaryGetValue(signingInfo, kSecCodeInfoEntitlementsDict);
	if(entitlements == NULL)
	{
		NSLog(@"[dumpEntitlements] no entitlements specified");
	}
	else if(CFGetTypeID(entitlements) != CFDictionaryGetTypeID())
	{
		NSLog(@"[dumpEntitlements] invalid entitlements");
	}
	else
	{
		entitlementsNSDict = (__bridge NSDictionary *)(entitlements);
		NSLog(@"[dumpEntitlements] dumped %@", entitlementsNSDict);
	}
	
	CFRelease(signingInfo);
	return entitlementsNSDict;
}
SecStaticCodeRef getStaticCodeRef(NSString *binaryPath)
{
	if(binaryPath == nil)
	{
		return NULL;
	}
	
	CFURLRef binaryURL = CFURLCreateWithFileSystemPath(kCFAllocatorDefault, (__bridge CFStringRef)binaryPath, kCFURLPOSIXPathStyle, false);
	if(binaryURL == NULL)
	{
		NSLog(@"[getStaticCodeRef] failed to get URL to binary %@", binaryPath);
		return NULL;
	}
	
	SecStaticCodeRef codeRef = NULL;
	OSStatus result;
	
	result = SecStaticCodeCreateWithPathAndAttributes(binaryURL, kSecCSDefaultFlags, NULL, &codeRef);
	
	CFRelease(binaryURL);
	
	if(result != errSecSuccess)
	{
		NSLog(@"[getStaticCodeRef] failed to create static code for binary %@", binaryPath);
		return NULL;
	}
		
	return codeRef;
}
NSSet<NSString*>* immutableAppBundleIdentifiers(void)
{
	NSMutableSet* systemAppIdentifiers = [NSMutableSet new];

	LSEnumerator* enumerator = [LSEnumerator enumeratorForApplicationProxiesWithOptions:0];
	LSApplicationProxy* appProxy;
	while(appProxy = [enumerator nextObject])
	{
		if(appProxy.installed)
		{
			if(![appProxy.bundleURL.path hasPrefix:@"/private/var/containers"])
			{
				[systemAppIdentifiers addObject:appProxy.bundleIdentifier.lowercaseString];
			}
		}
	}

	return systemAppIdentifiers.copy;
}
NSDictionary* dumpEntitlementsFromBinaryAtPath(NSString *binaryPath)
{
	// This function is intended for one-shot checks. Main-event functions should retain/release their own SecStaticCodeRefs
	
	if(binaryPath == nil)
	{
		return nil;
	}
	
	SecStaticCodeRef codeRef = getStaticCodeRef(binaryPath);
	if(codeRef == NULL)
	{
		return nil;
	}
	
	NSDictionary *entitlements = dumpEntitlements(codeRef);
	CFRelease(codeRef);
	
	return entitlements;
}

void refreshAppRegistrations()
{
	//registerPath((char*)trollStoreAppPath().UTF8String, 1);
	registerPath((char*)trollStoreAppPath().UTF8String, 0);

	for(NSString* appPath in trollStoreInstalledAppBundlePaths())
	{
		//registerPath((char*)appPath.UTF8String, 1);
		registerPath((char*)appPath.UTF8String, 0);
	}
}

BOOL _installPersistenceHelper(LSApplicationProxy* appProxy, NSString* sourcePersistenceHelper, NSString* sourceRootHelper)
{
	NSLog(@"_installPersistenceHelper(%@, %@, %@)", appProxy, sourcePersistenceHelper, sourceRootHelper);

	NSString* executablePath = appProxy.canonicalExecutablePath;
	NSString* bundlePath = appProxy.bundleURL.path;
	if(!executablePath)
	{
		NSBundle* appBundle = [NSBundle bundleWithPath:bundlePath];
		executablePath = [bundlePath stringByAppendingPathComponent:[appBundle objectForInfoDictionaryKey:@"CFBundleExecutable"]];
	}

	NSString* markPath = [bundlePath stringByAppendingPathComponent:@".TrollStorePersistenceHelper"];
	NSString* rootHelperPath = [bundlePath stringByAppendingPathComponent:@"trollstorehelper"];

	// remove existing persistence helper binary if exists
	if([[NSFileManager defaultManager] fileExistsAtPath:markPath] && [[NSFileManager defaultManager] fileExistsAtPath:executablePath])
	{
		[[NSFileManager defaultManager] removeItemAtPath:executablePath error:nil];
	}

	// remove existing root helper binary if exists
	if([[NSFileManager defaultManager] fileExistsAtPath:rootHelperPath])
	{
		[[NSFileManager defaultManager] removeItemAtPath:rootHelperPath error:nil];
	}

	// install new persistence helper binary
	if(![[NSFileManager defaultManager] copyItemAtPath:sourcePersistenceHelper toPath:executablePath error:nil])
	{
		return NO;
	}

	chmod(executablePath.UTF8String, 0755);
	chown(executablePath.UTF8String, 33, 33);

	NSError* error;
	if(![[NSFileManager defaultManager] copyItemAtPath:sourceRootHelper toPath:rootHelperPath error:&error])
	{
		NSLog(@"error copying root helper: %@", error);
	}

	chmod(rootHelperPath.UTF8String, 0755);
	chown(rootHelperPath.UTF8String, 0, 0);

	// mark system app as persistence helper
	if(![[NSFileManager defaultManager] fileExistsAtPath:markPath])
	{
		[[NSFileManager defaultManager] createFileAtPath:markPath contents:[NSData data] attributes:nil];
	}

	return YES;
}


int main(int argc, char *argv[], char *envp[]) {
	@autoreleasepool {
        [[NSFileManager defaultManager] createDirectoryAtPath:@"/var/mobile/testrebuild" withIntermediateDirectories:true attributes:nil error:nil];

		loadMCMFramework();
        NSString* action = [NSString stringWithUTF8String:argv[1]];
        NSString* source = [NSString stringWithUTF8String:argv[2]];
        NSString* destination = [NSString stringWithUTF8String:argv[3]];


        if ([action isEqual: @"filemove"]) {
            [[NSFileManager defaultManager] moveItemAtPath:source toPath:destination error:nil];
        } else if ([action isEqual: @"filecopy"]) {
            [[NSFileManager defaultManager] copyItemAtPath:source toPath:destination error:nil];
        } else if ([action isEqual: @"makedirectory"]) {
            [[NSFileManager defaultManager] createDirectoryAtPath:source withIntermediateDirectories:true attributes:nil error:nil];
        } else if ([action isEqual: @"removeitem"]) {
            [[NSFileManager defaultManager] removeItemAtPath:source error:nil];
        } else if ([action isEqual: @"permissionset"]) {
            NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
            [dict setObject:[NSNumber numberWithInt:511]  forKey:NSFilePosixPermissions];
            [[NSFileManager defaultManager] setAttributes:dict ofItemAtPath:source error:nil];
        } else if ([action isEqual: @"rebuildiconcache"]) {
            [[LSApplicationWorkspace defaultWorkspace] _LSPrivateRebuildApplicationDatabasesForSystemApps:YES internal:YES user:YES];
            refreshAppRegistrations(); // needed for trollstore apps still working after rebuilding, otherwise they won't launch
            respring();
        }

        // NSLog(@"%s", getuid() == 0 ? "root" : "user");
        return 0;
    }
}