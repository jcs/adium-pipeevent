#import <Cocoa/Cocoa.h>
#import <Adium/AIPlugin.h>
#import <Adium/AISharedAdium.h>
#import <Adium/AIContactAlertsControllerProtocol.h>

#define KEY_COMMAND			@"PipeEvent"

@protocol AIContentFilter;

@interface PipeEventPlugin : AIPlugin <AIActionHandler> {
}

@end

