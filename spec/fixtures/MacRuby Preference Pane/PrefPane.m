//
// PrefPane.m
// �PROJECTNAME�
//
// Created by �FULLUSERNAME� on �DATE�.
// Copyright �ORGANIZATIONNAME� �YEAR�. All rights reserved.
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