//
//  ZTypewriteEffectLabel.m
//  ZTypewriteEffect
//
//  Created by mapboo on 7/27/14.
//  Copyright (c) 2014 mapboo. All rights reserved.
//

#import "ZTypewriteEffectLabel.h"

@implementation ZTypewriteEffectLabel

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.hasSound = NO;
        self.typewriteTimeInterval = 0.01;
    }
    return self;
}

-(void)startTypewrite
{
    [NSTimer scheduledTimerWithTimeInterval:self.typewriteTimeInterval target:self selector:@selector(outPutWord:) userInfo:nil repeats:YES];
}


-(void)outPutWord:(id)atimer
{
    if (self.text.length == self.currentIndex) {
       [atimer invalidate];
        atimer = nil;
    }else{
        self.currentIndex++;
        NSDictionary *dic = @{NSForegroundColorAttributeName:self.typewriteEffectColor};
        NSMutableAttributedString *mutStr = [[NSMutableAttributedString alloc] initWithString:self.text];
        [mutStr addAttributes:dic range:NSMakeRange(0, self.currentIndex)];
        [self setAttributedText:mutStr];
    }
}

- (void)removeAllSetting
{
    if (_currentIndex != 0) {
        self.currentIndex = 0;

    }
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
