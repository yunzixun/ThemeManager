//
//  Supplementary+zhTheme.m
//  ThemeManager
//
//  Created by zhanghao on 2017/5/29.
//  Copyright © 2017年 snail-z. All rights reserved.
//

#import "Supplementary+zhTheme.h"
#import "NSObject+zhTheme.h"
#import <objc/runtime.h>

@interface UINavigationBar ()

@property (nonatomic, strong, readonly) NSMutableDictionary<NSString *, id> *zh_overPickers;

@end

@implementation UINavigationBar (zhThemeOverlay)

- (NSMutableDictionary<NSString *,id> *)zh_overPickers {
    return addListener(self, _cmd, @selector(zhThemeUpdateOverlayViewColor));
}

- (void)zhThemeUpdateOverlayViewColor {
    [self.zh_overPickers enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, zhThemePicker *  _Nonnull picker, BOOL * _Nonnull stop) {
        if ([[picker valueForKey:@"isAnimated"] boolValue]) {
            [UIView animateWithDuration:ThemeManager.changeThemeColorAnimationDuration animations:^{
                [self zh_setOverlayViewBackgroundColor:picker.themeColor];
            }];
        } else {
            [self zh_setOverlayViewBackgroundColor:picker.themeColor];
        }
    }];
}

- (UIView *)zh_overlayView {
    UIView *overlayView = objc_getAssociatedObject(self, _cmd);
    if (!overlayView) {
        overlayView = [[UIView alloc] init];
        overlayView.frame = CGRectMake(0, -20, UIScreen.mainScreen.bounds.size.width, 20);
        overlayView.userInteractionEnabled = NO;
        overlayView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self addSubview:overlayView];
        objc_setAssociatedObject(self, _cmd, overlayView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return overlayView;
}

- (void)zh_setOverlayViewBackgroundColor:(UIColor *)color {
    self.layer.backgroundColor = color.CGColor;
    self.zh_overlayView.backgroundColor = color;
}

- (zhThemePicker *)zh_overlayColorPicker {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setZh_overlayColorPicker:(zhThemePicker *)zh_overlayColorPicker {
    if (!zh_overlayColorPicker) {
        [self setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
        [self.zh_overlayView removeFromSuperview];
        objc_setAssociatedObject(self, @selector(zh_overlayView), nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        [self.zh_overPickers removeObjectForKey:NSStringFromSelector(@selector(zh_setOverlayViewBackgroundColor:))];
        return;
    }
    [self setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    objc_setAssociatedObject(self, @selector(zh_overlayColorPicker), zh_overlayColorPicker, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self zh_setOverlayViewBackgroundColor:zh_overlayColorPicker.themeColor];
    [self.zh_overPickers setObject:zh_overlayColorPicker forKey:NSStringFromSelector(@selector(zh_setOverlayViewBackgroundColor:))];
}

@end

@implementation UITabBar (zhThemeOverlay)

- (UIView *)zh_overlayView {
    UIView *overlayView = objc_getAssociatedObject(self, _cmd);
    if (!overlayView) {
        overlayView = [[UIView alloc] init];
        overlayView.frame = CGRectMake(0, 0, UIScreen.mainScreen.bounds.size.width, self.bounds.size.height);
        overlayView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self insertSubview:overlayView atIndex:0];
        objc_setAssociatedObject(self, _cmd, overlayView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return overlayView;
}

- (zhThemePicker *)zh_overlayColorPicker {
    return getThemePicker(self, _cmd);
}

- (void)setZh_overlayColorPicker:(zhThemePicker *)zh_overlayColorPicker {
    setThemePicker(zh_overlayColorPicker, self, @"zh_overlayView.backgroundColor");
}

@end
