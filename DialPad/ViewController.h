//
//  ViewController.h
//  DialPad
//
//  Created by ZxMYS on 14/10/25.
//

#import <Cocoa/Cocoa.h>
@class ViewController;


@interface DraggableWindow:NSWindow
@property(weak) id delegate;
@end


@interface ZeroButton : NSView
@property(weak) ViewController* delegate;
@end
@interface ViewController : NSViewController

- (void)verticalizeButtonsForWindow:(NSWindow *)aWindow;

@property (weak) IBOutlet NSTextField *lblNumber;
@property (weak) IBOutlet ZeroButton *zero;

@property (weak) IBOutlet NSButton *btnDial;
- (IBAction)dialClicked:(id)sender;
- (IBAction)numberClicked:(id)sender;
- (IBAction)closeClicked:(id)sender;
-(void)addZero;
-(void)changeToPlus;
@end

