//
//  TUIVoiceMessageCell.m
//  UIKit
//
//  Created by annidyfeng on 2019/5/30.
//

#import "TUIVoiceMessageCell.h"
#import "TUIDefine.h"

@implementation TUIVoiceMessageCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _voice = [[UIImageView alloc] init];
        _voice.animationDuration = 1;
        [self.bubbleView addSubview:_voice];

        _duration = [[UILabel alloc] init];
        _duration.font = [UIFont boldSystemFontOfSize:12];
        _duration.textColor = [UIColor blackColor];
        [self.bubbleView addSubview:_duration];

        _voiceReadPoint = [[UIImageView alloc] init];
        _voiceReadPoint.backgroundColor = [UIColor redColor];
        _voiceReadPoint.frame = CGRectMake(0, 0, 5, 5);
        _voiceReadPoint.hidden = YES;
        [_voiceReadPoint.layer setCornerRadius:_voiceReadPoint.frame.size.width/2];
        [_voiceReadPoint.layer setMasksToBounds:YES];
        [self.bubbleView addSubview:_voiceReadPoint];
    }
    return self;
}

- (void)fillWithData:(TUIVoiceMessageCellData *)data;
{
    //set data
    [super fillWithData:data];
    self.voiceData = data;
    if (data.duration > 0) {
        _duration.text = [NSString stringWithFormat:@"%ld\"", (long)data.duration];
    } else {
        _duration.text = @"1\"";    // 显示0秒容易产生误解
    }
    _voice.image = data.voiceImage;
    _voice.animationImages = data.voiceAnimationImages;
    
    //voiceReadPoint
    //此处0为语音消息未播放，1为语音消息已播放
    //发送出的消息，不展示红点
    if(self.voiceData.innerMessage.localCustomInt == 0 && self.voiceData.direction == MsgDirectionIncoming)
        self.voiceReadPoint.hidden = NO;

    //animate
    @weakify(self)
    [[RACObserve(data, isPlaying) takeUntil:self.rac_prepareForReuseSignal] subscribeNext:^(NSNumber *x) {
        @strongify(self)
        if ([x boolValue]) {
            [self.voice startAnimating];
        } else {
            [self.voice stopAnimating];
        }
    }];
    if (data.direction == MsgDirectionIncoming) {
        _duration.textAlignment = NSTextAlignmentLeft;
    } else {
        _duration.textAlignment = NSTextAlignmentRight;
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.duration.mm_sizeToFitThan(10,TVoiceMessageCell_Duration_Size.height);
    
    self.voice.mm_sizeToFit().mm_top(self.voiceData.voiceTop);
    
    if (self.voiceData.direction == MsgDirectionOutgoing) {
        self.bubbleView.mm_left(self.duration.mm_w).mm_flexToRight(0);
        self.voice.mm_right(self.voiceData.cellLayout.bubbleInsets.right);
        self.duration.mm_left(self.voice.mm_x - self.duration.mm_w - 5);
        self.voiceReadPoint.hidden = YES;
    } else {
        self.bubbleView.mm_left(0).mm_flexToRight(self.duration.mm_w);
        self.voice.mm_left(self.voiceData.cellLayout.bubbleInsets.left);
        self.duration.mm_left(self.voice.mm_x + self.voice.mm_w + 5);
//        self.voiceReadPoint.mm_bottom(self.duration.mm_y + self.duration.mm_h).mm_left(self.duration.mm_x);
        self.voiceReadPoint.mm_top(0).mm_right(-self.voiceReadPoint.mm_w);
    }
    self.duration.mm_centerY = self.voice.mm_centerY;
}


@end

