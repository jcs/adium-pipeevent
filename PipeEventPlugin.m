#import "PipeEventPlugin.h"
#import "PipeEventDetailPane.h"
#import <AIUtilities/AIImageAdditions.h>
#import <Adium/AIContentObject.h>
#import <Adium/AIListContact.h>

#define PIPE_EVENT_IDENTIFIER		@"PipeEvent"
#define	PIPE_EVENT_SHORT		@"Pipe event to command"
#define	PIPE_EVENT_LONG			@"Pipe event to \"%@\""

@implementation PipeEventPlugin

- (void)installPlugin
{	
	[adium.contactAlertsController registerActionID:PIPE_EVENT_IDENTIFIER withHandler:self];
}

/* text for the "Action:" drop down */
- (NSString *)shortDescriptionForActionID:(NSString *)actionID
{
	return PIPE_EVENT_SHORT;
}

/* subtext for the "When you receive any message" line, and the text in the full events list */
- (NSString *)longDescriptionForActionID:(NSString *)actionID
			     withDetails:(NSDictionary *)details
{
	NSString	*command = [details objectForKey:KEY_COMMAND];

	if (command && [command length])
		return [NSString stringWithFormat:PIPE_EVENT_LONG, [command lastPathComponent]];
	else
		return PIPE_EVENT_SHORT;
}

- (NSImage *)imageForActionID:(NSString *)actionID
{
	return [NSImage imageNamed:@"TerminalIcon" forClass:[self class]];
}

- (AIModularPane *)detailsPaneForActionID:(NSString *)actionID
{
	return [PipeEventDetailPane actionDetailsPane];
}

/* the actual event handler */
- (BOOL)performActionID:(NSString *)actionID
		  forListObject:(AIListObject *)listObject
		    withDetails:(NSDictionary *)details
	      triggeringEventID:(NSString *)eventID
		       userInfo:(id)userInfo
{
	NSString	*command = [details objectForKey:KEY_COMMAND];
	NSString	*message = [adium.contactAlertsController naturalLanguageDescriptionForEventID:eventID
											   listObject:listObject
											     userInfo:userInfo
										       includeSubject:NO];
	NSString	*sender;
	AIChat		*chat = nil;

	NSTask		*task = [[NSTask alloc] init];

	[task setLaunchPath:command];

	// for a message event, listObject should become whoever sent the message
	if ([adium.contactAlertsController isMessageEvent:eventID] &&
		[userInfo respondsToSelector:@selector(objectForKey:)] &&
		[userInfo objectForKey:@"AIContentObject"]) {
		AIContentObject	*contentObject = [userInfo objectForKey:@"AIContentObject"];
		AIListObject	*source = [contentObject source];
		chat = [userInfo objectForKey:@"AIChat"];

		if (source)
			listObject = source;
	}

	if (listObject) {
		if ([listObject isKindOfClass:[AIListContact class]]) {
			// use the parent
			listObject = [(AIListContact *)listObject parentContact];
			sender = [listObject longDisplayName];
		} else
			sender = listObject.displayName;
	} else if (chat)
		sender = chat.displayName;

	// pass the sender (or whatever the event sends) as the first arg
	if (sender)
		[task setArguments:[NSArray arrayWithObjects:sender, nil]];

	// stdout and stderr will be closed right away
	[task setStandardOutput:[NSPipe pipe]];
	[task setStandardError:[NSPipe pipe]];
	[task setStandardInput:[NSPipe pipe]];

	// go go gadget nstask
	[task launch];

	// close command's stdout and stderr
	[[[task standardOutput] fileHandleForReading] closeFile];
	[[[task standardError] fileHandleForReading] closeFile];

	// send the message contents (with newline) and then close the filehandle
	[[[task standardInput] fileHandleForWriting] writeData:[[NSString stringWithFormat:@"%@\n", message] dataUsingEncoding:NSASCIIStringEncoding]];
	[[[task standardInput] fileHandleForWriting] closeFile];

	// uh, i guess magic happens here and everything is cleaned up for us

	return YES; // WE CAN
}

- (BOOL)allowMultipleActionsWithID:(NSString *)actionID
{
	/* we can be setup with different commands for different things, so, yeah */
	return YES;
}

- (NSString *)pluginAuthor
{
	return @"joshua stein";
}

- (NSString *)pluginVersion
{
	return @"1.0";
}

- (NSString *)pluginDescription
{
	return @"This plugin pipes events to an external command."; // with gusto!
}

- (NSString *)pluginURL
{
	return @"http://jcs.org/";
}

@end
