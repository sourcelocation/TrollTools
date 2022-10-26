@import Foundation;

int main(int argc, char *argv[], char *envp[]) {
    NSString* action = [NSString stringWithUTF8String:argv[1]];
    NSString* source = [NSString stringWithUTF8String:argv[2]];
    NSString* destination = [NSString stringWithUTF8String:argv[3]];
    // NSBundle* bundle = [NSBundle bundleWithPath:@"/System/Library/PrivateFrameworks/MobileContainerManager.framework"];
    // [bundle load];

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
    }

    // NSLog(@"%s", getuid() == 0 ? "root" : "user");
    return 1;
}