//
//  NSString+TRUI.h
//  TRUI
//
//  Created by Mac on 2020/4/26.
//  Copyright © 2020 Mac. All rights reserved.
//
#import <Foundation/Foundation.h>
#import <CoreGraphics/CGBase.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSString (TRUI)

/// 将字符串按一个一个字符拆成数组，类似 JavaScript 里的 split("")，如果多个空格，则每个空格也会当成一个 item
@property(nullable, readonly, copy) NSArray<NSString *> *trui_toArray;

/// 将字符串按一个一个字符拆成数组，类似 JavaScript 里的 split("")，但会自动过滤掉空白字符
@property(nullable, readonly, copy) NSArray<NSString *> *trui_toTrimmedArray;

/// 去掉头尾的空白字符
@property(readonly, copy) NSString *trui_trim;

/// 去掉整段文字内的所有空白字符（包括换行符）
@property(readonly, copy) NSString *trui_trimAllWhiteSpace;

/// 将文字中的换行符替换为空格
@property(readonly, copy) NSString *trui_trimLineBreakCharacter;

/// 把该字符串转换为对应的 md5
@property(readonly, copy) NSString *trui_md5;

/// 返回一个符合 query value 要求的编码后的字符串，例如&、#、=等字符均会被变为 %xxx 的编码
/// @see `NSCharacterSet (TRUI) trui_URLUserInputQueryAllowedCharacterSet`
@property(nullable, readonly, copy) NSString *trui_stringByEncodingUserInputQuery;

/// 把当前文本的第一个字符改为大写，其他的字符保持不变，例如 backgroundView.trui_capitalizedString -> BackgroundView（系统的 capitalizedString 会变成 Backgroundview）
@property(nullable, readonly, copy) NSString *trui_capitalizedString;

/**
 * 用正则表达式匹配的方式去除字符串里一些特殊字符，避免UI上的展示问题
 * @link http://www.croton.su/en/uniblock/Diacriticals.html @/link
 */
@property(nullable, readonly, copy) NSString *trui_removeMagicalChar;

/**
 *  按照中文 2 个字符、英文 1 个字符的方式来计算文本长度
 */
@property(readonly) NSUInteger trui_lengthWhenCountingNonASCIICharacterAsTwo;

/**
 *  将字符串从指定的 index 开始裁剪到结尾，裁剪时会避免将 emoji 等 "character sequences" 拆散（一个 emoji 表情占用1-4个长度的字符）。
 *
 *  例如对于字符串“😊😞”，它的长度为4，若调用 [string trui_substringAvoidBreakingUpCharacterSequencesFromIndex:1]，将返回“😊😞”。
 *  若调用系统的 [string substringFromIndex:1]，将返回“?😞”。（?表示乱码，因为第一个 emoji 表情被从中间裁开了）。
 *
 *  @param index 要从哪个 index 开始裁剪文字
 *  @param lessValue 要按小的长度取，还是按大的长度取
 *  @param countingNonASCIICharacterAsTwo 是否按照 英文 1 个字符长度、中文 2 个字符长度的方式来裁剪
 *  @return 裁剪完的字符
 */
- (NSString *)trui_substringAvoidBreakingUpCharacterSequencesFromIndex:(NSUInteger)index lessValue:(BOOL)lessValue countingNonASCIICharacterAsTwo:(BOOL)countingNonASCIICharacterAsTwo;

/**
 *  相当于 `trui_substringAvoidBreakingUpCharacterSequencesFromIndex: lessValue:YES` countingNonASCIICharacterAsTwo:NO
 *  @see trui_substringAvoidBreakingUpCharacterSequencesFromIndex:lessValue:countingNonASCIICharacterAsTwo:
 */
- (NSString *)trui_substringAvoidBreakingUpCharacterSequencesFromIndex:(NSUInteger)index;

/**
 *  将字符串从开头裁剪到指定的 index，裁剪时会避免将 emoji 等 "character sequences" 拆散（一个 emoji 表情占用1-4个长度的字符）。
 *
 *  例如对于字符串“😊😞”，它的长度为4，若调用 [string trui_substringAvoidBreakingUpCharacterSequencesToIndex:1 lessValue:NO countingNonASCIICharacterAsTwo:NO]，将返回“😊”。
 *  若调用系统的 [string substringToIndex:1]，将返回“?”。（?表示乱码，因为第一个 emoji 表情被从中间裁开了）。
 *
 *  @param index 要裁剪到哪个 index
 *  @param lessValue 裁剪时若遇到“character sequences”，是向下取整还是向上取整。
 *  @param countingNonASCIICharacterAsTwo 是否按照 英文 1 个字符长度、中文 2 个字符长度的方式来裁剪
 *  @return 裁剪完的字符
 */
- (NSString *)trui_substringAvoidBreakingUpCharacterSequencesToIndex:(NSUInteger)index lessValue:(BOOL)lessValue countingNonASCIICharacterAsTwo:(BOOL)countingNonASCIICharacterAsTwo;

/**
 *  相当于 `trui_substringAvoidBreakingUpCharacterSequencesToIndex:lessValue:YES` countingNonASCIICharacterAsTwo:NO
 *  @see trui_substringAvoidBreakingUpCharacterSequencesToIndex:lessValue:countingNonASCIICharacterAsTwo:
 */
- (NSString *)trui_substringAvoidBreakingUpCharacterSequencesToIndex:(NSUInteger)index;

/**
 *  将字符串里指定 range 的子字符串裁剪出来，会避免将 emoji 等 "character sequences" 拆散（一个 emoji 表情占用1-4个长度的字符）。
 *
 *  例如对于字符串“😊😞”，它的长度为4，在 lessValue 模式下，裁剪 (0, 1) 得到的是空字符串，裁剪 (0, 2) 得到的是“😊”。
 *  在非 lessValue 模式下，裁剪 (0, 1) 或 (0, 2)，得到的都是“😊”。
 *
 *  @param range 要裁剪的文字位置
 *  @param lessValue 裁剪时若遇到“character sequences”，是向下取整还是向上取整。
 *  @param countingNonASCIICharacterAsTwo 是否按照 英文 1 个字符长度、中文 2 个字符长度的方式来裁剪
 *  @return 裁剪完的字符
 */
- (NSString *)trui_substringAvoidBreakingUpCharacterSequencesWithRange:(NSRange)range lessValue:(BOOL)lessValue countingNonASCIICharacterAsTwo:(BOOL)countingNonASCIICharacterAsTwo;

/**
 *  相当于 `trui_substringAvoidBreakingUpCharacterSequencesWithRange:lessValue:YES` countingNonASCIICharacterAsTwo:NO
 *  @see trui_substringAvoidBreakingUpCharacterSequencesWithRange:lessValue:countingNonASCIICharacterAsTwo:
 */
- (NSString *)trui_substringAvoidBreakingUpCharacterSequencesWithRange:(NSRange)range;

/**
 *  移除指定位置的字符，可兼容emoji表情的情况（一个emoji表情占1-4个length）
 *  @param index 要删除的位置
 */
- (NSString *)trui_stringByRemoveCharacterAtIndex:(NSUInteger)index;

/**
 *  移除最后一个字符，可兼容emoji表情的情况（一个emoji表情占1-4个length）
 *  @see `trui_stringByRemoveCharacterAtIndex:`
 */
- (NSString *)trui_stringByRemoveLastCharacter;

/**
 用正则表达式匹配字符串，将匹配到的第一个结果返回，大小写不敏感

 @param pattern 正则表达式
 @return 匹配到的第一个结果，如果没有匹配成功则返回 nil
 */
- (NSString *)trui_stringMatchedByPattern:(NSString *)pattern;

/**
 *  用正则表达式匹配字符串并将其替换为指定的另一个字符串，大小写不敏感
 *  @param pattern 正则表达式
 *  @param replacement 要替换为的字符串
 *  @return 最终替换后的完整字符串，如果正则表达式匹配不成功则返回原字符串
 */
- (NSString *)trui_stringByReplacingPattern:(NSString *)pattern withString:(NSString *)replacement;

/// 把某个十进制数字转换成十六进制的数字的字符串，例如“10”->“A”
+ (NSString *)trui_hexStringWithInteger:(NSInteger)integer;

/// 把参数列表拼接成一个字符串并返回，相当于用另一种语法来代替 [NSString stringWithFormat:]
+ (NSString *)trui_stringByConcat:(id)firstArgv, ...;

/**
 * 将秒数转换为同时包含分钟和秒数的格式的字符串，例如 100->"01:40"
 */
+ (NSString *)trui_timeStringWithMinsAndSecsFromSecs:(double)seconds;

@end

@interface NSString (TRUI_StringFormat)

+ (instancetype)trui_stringWithNSInteger:(NSInteger)integerValue;
+ (instancetype)trui_stringWithCGFloat:(CGFloat)floatValue;
+ (instancetype)trui_stringWithCGFloat:(CGFloat)floatValue decimal:(NSUInteger)decimal;
@end

NS_ASSUME_NONNULL_END
