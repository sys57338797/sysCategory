//
//  UILabel+textHeight.m
//  CWGJCarOwner
//
//  Created by mutouren on 12/8/15.
//  Copyright © 2015 mutouren. All rights reserved.
//

#import "UILabel+textSize.h"
#import "NSString+Extension.h"


@implementation UILabel (textSize)


- (CGFloat)textHeight
{
    return [self.text boundingRectWithSize:CGSizeMake(self.frame.size.width, MAXFLOAT)
                                   options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading
                                attributes:@{NSFontAttributeName:self.font}
                                   context:nil].size.height;
}

- (NSInteger)textLineCount
{
    return [self.text lineCountForFont:self.font maxWidth:CGRectGetWidth(self.frame)];
}

- (CGFloat)textALineWidth
{
    return [self.text sizeWithAttributes:@{NSFontAttributeName:self.font}].width;
}

- (CGFloat)textALineHeight
{
    return [self.text sizeWithAttributes:@{NSFontAttributeName:self.font}].height;
}

@end
