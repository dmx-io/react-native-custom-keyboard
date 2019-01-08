#import "RNCustomKeyboard.h"
#import <React/RCTUIManager.h>
#import <RCTText/RCTBaseTextInputView.h>
#import <sys/utsname.h>

@implementation RNCustomKeyboard
@synthesize bridge = _bridge;

- (dispatch_queue_t)methodQueue
{
    return dispatch_get_main_queue();
}

RCT_EXPORT_MODULE(CustomKeyboard);

int additionalHeight = 34;
int keyboardHeight = 218;

- (BOOL) isIphoneX {
    struct utsname systemInfo;
    uname(&systemInfo);
    
    NSString* deviceModel = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
    return [deviceModel isEqualToString:@"iPhone10,3"] || [deviceModel isEqualToString:@"iPhone10,6"];
};

RCT_EXPORT_METHOD(install:(nonnull NSNumber *)reactTag withType:(nonnull NSString *)keyboardType) {
    UIView* inputView = [[RCTRootView alloc] initWithBridge:_bridge moduleName:@"CustomKeyboard" initialProperties:
                         @{
                           @"tag": reactTag,
                           @"type": keyboardType
                           }
                         ];
    
    inputView.autoresizingMask = UIViewAutoresizingNone;
    
    if ([self isIphoneX]) {
        inputView.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, keyboardHeight + additionalHeight);
    } else {
        inputView.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, keyboardHeight);
    }
    
    UITextField *view = (UITextField *)(((RCTBaseTextInputView*)[_bridge.uiManager viewForReactTag:reactTag]).backedTextInputView);
    
    view.inputView = inputView;
    [view reloadInputViews];
}

RCT_EXPORT_METHOD(uninstall:(nonnull NSNumber *)reactTag) {
    UITextField *view = (UITextField *)(((RCTBaseTextInputView*)[_bridge.uiManager viewForReactTag:reactTag]).backedTextInputView);
    
    view.inputView = nil;
    [view reloadInputViews];
}

RCT_EXPORT_METHOD(hideKeyboard:(nonnull NSNumber *)reactTag) {
    UITextField *view = (UITextField *)(((RCTBaseTextInputView*)[_bridge.uiManager viewForReactTag:reactTag]).backedTextInputView);
    
    [view endEditing:YES];
}

RCT_EXPORT_METHOD(submitEditing:(nonnull NSNumber *)reactTag) {
    UITextField *view = (UITextField *)(((RCTBaseTextInputView*)[_bridge.uiManager viewForReactTag:reactTag]).backedTextInputView);
    
    [view endEditing:YES];
    
    [_bridge.eventDispatcher sendTextEventWithType:RCTTextEventTypeSubmit
                                          reactTag:reactTag
                                              text:view.attributedText.string
                                               key:nil
                                        eventCount:0];
}

RCT_EXPORT_METHOD(insertText:(nonnull NSNumber *)reactTag withText:(NSString*)text) {
    UITextField *view = (UITextField *)(((RCTBaseTextInputView*)[_bridge.uiManager viewForReactTag:reactTag]).backedTextInputView);
    
    [view replaceRange:view.selectedTextRange withText:text];
}

RCT_EXPORT_METHOD(backSpace:(nonnull NSNumber *)reactTag) {
    UITextField *view = (UITextField *)(((RCTBaseTextInputView*)[_bridge.uiManager viewForReactTag:reactTag]).backedTextInputView);
    UITextRange* range = view.selectedTextRange;
    
    if ([view comparePosition:range.start toPosition:range.end] == 0) {
        range = [view textRangeFromPosition:[view positionFromPosition:range.start offset:-1] toPosition:range.start];
    }
    
    [view replaceRange:range withText:@""];
}

RCT_EXPORT_METHOD(doDelete:(nonnull NSNumber *)reactTag) {
    UITextField *view = (UITextField *)(((RCTBaseTextInputView*)[_bridge.uiManager viewForReactTag:reactTag]).backedTextInputView);
    UITextRange* range = view.selectedTextRange;
    
    if ([view comparePosition:range.start toPosition:range.end] == 0) {
        range = [view textRangeFromPosition:range.start toPosition:[view positionFromPosition: range.start offset: 1]];
    }
    
    [view replaceRange:range withText:@""];
}

RCT_EXPORT_METHOD(moveLeft:(nonnull NSNumber *)reactTag) {
    UITextField *view = (UITextField *)(((RCTBaseTextInputView*)[_bridge.uiManager viewForReactTag:reactTag]).backedTextInputView);
    UITextRange* range = view.selectedTextRange;
    UITextPosition* position = range.start;
    
    if ([view comparePosition:range.start toPosition:range.end] == 0) {
        position = [view positionFromPosition: position offset: -1];
    }
    
    view.selectedTextRange = [view textRangeFromPosition: position toPosition:position];
}

RCT_EXPORT_METHOD(moveRight:(nonnull NSNumber *)reactTag) {
    UITextField *view = (UITextField *)(((RCTBaseTextInputView*)[_bridge.uiManager viewForReactTag:reactTag]).backedTextInputView);
    UITextRange* range = view.selectedTextRange;
    UITextPosition* position = range.end;
    
    if ([view comparePosition:range.start toPosition:range.end] == 0) {
        position = [view positionFromPosition: position offset: 1];
    }
    
    view.selectedTextRange = [view textRangeFromPosition: position toPosition:position];
}

RCT_EXPORT_METHOD(switchSystemKeyboard:(nonnull NSNumber*) reactTag) {
    UITextField *view = (UITextField *)(((RCTBaseTextInputView*)[_bridge.uiManager viewForReactTag:reactTag]).backedTextInputView);
    UIView* inputView = view.inputView;
    
    view.inputView = nil;
    [view reloadInputViews];
    view.inputView = inputView;
}

@end
