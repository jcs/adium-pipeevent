#import "PipeEventPlugin.h"
#import "PipeEventDetailPane.h"

@implementation PipeEventDetailPane

- (NSString *)nibName{
    return @"PipeEvent";    
}

/* put the command back in the text field */
- (void)configureForActionDetails:(NSDictionary *)inDetails listObject:(AIListObject *)inObject
{
    NSString *command = [inDetails objectForKey:KEY_COMMAND];
    [text_command setStringValue:(command ? command : @"")];
	
    [super configureForActionDetails:inDetails listObject:inObject];
}

- (NSDictionary *)actionDetails
{
	if ([text_command stringValue]) {
		return [NSDictionary dictionaryWithObject:[text_command stringValue] forKey:KEY_COMMAND];
	} else {
		return nil;
	}
}

@end

