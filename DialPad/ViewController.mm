//
//  ViewController.m
//  DialPad
//
//  Created by ZxMYS on 14/10/25.
//

#import "ViewController.h"
#import <phonenumbers/phonenumberutil.h>

using namespace i18n::phonenumbers;

@implementation DraggableWindow{
    NSPoint initialLocation;
    NSRect initialFrame;
}
@synthesize delegate;
- (void)keyDown:(NSEvent *)theEvent {
    [self.delegate keyDown:theEvent];
}
-(void)mouseDown:(NSEvent *)theEvent{
    initialLocation=[NSEvent mouseLocation];
    initialFrame=[self frame];
}
- (void)mouseDragged:(NSEvent *)theEvent
{
    NSPoint currentLocation;
    NSPoint newOrigin;
    
    NSRect  screenFrame = [[NSScreen mainScreen] frame];
    NSRect  windowFrame = [self frame];
    
    currentLocation = [NSEvent mouseLocation];
    newOrigin.x = currentLocation.x - initialLocation.x+initialFrame.origin.x;
    newOrigin.y = currentLocation.y - initialLocation.y+initialFrame.origin.y;
    
    if( (newOrigin.y+windowFrame.size.height) > (screenFrame.origin.y+screenFrame.size.height) ){
        newOrigin.y=screenFrame.origin.y + (screenFrame.size.height-windowFrame.size.height);
    }
    
    [self setFrameOrigin:newOrigin];
}
-(BOOL)canBecomeKeyWindow{
    return YES;
}

@end


@implementation ZeroButton{
    BOOL pressed;
    NSTimer *timer;
}
@synthesize delegate;
- (void)mouseDown:(NSEvent *)theEvent {
    pressed=YES;
    timer=[NSTimer scheduledTimerWithTimeInterval:0.7 target:self.delegate selector:@selector(changeToPlus) userInfo:nil repeats:NO];
    [self.delegate addZero];
}

- (void)mouseUp:(NSEvent *)theEvent {
    pressed=NO;
    [timer invalidate];
}

@end

@implementation ViewController{
    
}
@synthesize lblNumber,zero;
string input="";
PhoneNumberUtil *p=PhoneNumberUtil::GetInstance();

-(void)viewDidAppear{
    [super viewDidAppear];
    ((DraggableWindow*)self.view.window).delegate=self;

}
- (void)keyDown:(NSEvent *)theEvent {
    if(theEvent.characters.length==0)
        return;
    char c=[[theEvent.characters lowercaseString] characterAtIndex:0];
    
    if(c>='a'&&c<='z'){
        [self numberClicked:[self.view viewWithTag:20-c/122+5*c/16-'0']];
    }else if(c>='1'&&c<='9'){
        [self numberClicked:[self.view viewWithTag:c-'0']];
    }else if(c=='*'){
        [self numberClicked:[self.view viewWithTag:13]];
    }else if(c=='#'){
        [self numberClicked:[self.view viewWithTag:14]];
    }else if(c=='0'){
        [self numberClicked:[self.view viewWithTag:10]];
    }else if(c==127){
        [self numberClicked:[self.view viewWithTag:11]];
    }else if(c=='+'){
        [self numberClicked:[self.view viewWithTag:12]];
    }
        
}
- (void)viewDidLoad {
    [super viewDidLoad];
    zero.delegate=self;
    //[self setNextResponder:self.view];
    //[self.view.subviews enumerateObjectsUsingBlock:^(NSView *subview, NSUInteger idx, BOOL *stop) { [subview setNextResponder:self.view]; }];
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];
}

-(void)addZero{
    [self numberClicked:[self.view viewWithTag:10]];
}

-(void)changeToPlus{
    if(input.back()=='0'){
        input.pop_back();
        [self numberClicked:[self.view viewWithTag:12]];
    }
}

- (IBAction)dialClicked:(id)sender {
    if(!input.length())
        return;
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:[@"tel:" stringByAppendingString:[NSString stringWithCString:input.c_str() encoding:[NSString defaultCStringEncoding]]]]];
}

- (IBAction)numberClicked:(id)sender {
    long number=((NSButton*)sender).tag;
    if(number<11){
        char c=number%10+'0';
        input+=c;
    }else if(number==12){
        input+='+';
    }else if(number==13){
        input+='*';
    }else if(number==14){
        input+='#';
    }else{
        input.pop_back();
    }
    PhoneNumber n;
    NSString *r;
    NSString *locale=[[NSLocale currentLocale] localeIdentifier];
    locale=[locale substringFromIndex:locale.length-2];
    if((input.rfind('+')==string::npos||input.rfind('+')==0)&&input.find('*')==string::npos&&input.find('#')==string::npos&&p->Parse(input, [locale cStringUsingEncoding:NSUTF8StringEncoding], &n)==PhoneNumberUtil::NO_PARSING_ERROR){
        string result;
        if(input[0]!='+')
            p->Format(n,PhoneNumberUtil::NATIONAL,&result);
        else
            p->Format(n,PhoneNumberUtil::INTERNATIONAL,&result);
        
        r=[NSString stringWithCString:result.c_str() encoding:[NSString defaultCStringEncoding]];
    }else{
        r=[NSString stringWithCString:input.c_str() encoding:[NSString defaultCStringEncoding]];
    }
    if([r isEqual:@"0"])
        r=[NSString stringWithCString:input.c_str() encoding:[NSString defaultCStringEncoding]];
    if(r.length>15)
        r=[@"..." stringByAppendingString:[r substringFromIndex:r.length-12]];
    lblNumber.stringValue=r;

}

- (IBAction)closeClicked:(id)sender {
    exit(0);
}
@end
