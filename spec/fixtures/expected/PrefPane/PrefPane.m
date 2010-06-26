//
// PrefPane.m
// PrefPane
//
// Created by Eloy Duran on 26-06-10.
// Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import <MacRuby/MacRuby.h>
#import <PreferencePanes/PreferencePanes.h>

@interface PrefPane : NSPreferencePane
{}
@end

@implementation PrefPane

+ (void)initialize
{
  NSBundle *bundle = [NSBundle bundleForClass:[self class]];
  [[MacRuby sharedRuntime] evaluateFileAtPath:[bundle pathForResource:NSStringFromClass([self class]) ofType:@"rb"]];
}

@end