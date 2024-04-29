#if 0
#elif defined(__x86_64__) && __x86_64__
// Generated by Apple Swift version 5.10 (swiftlang-5.10.0.13 clang-1500.3.9.4)
#ifndef LOOPMEUNITEDSDK_SWIFT_H
#define LOOPMEUNITEDSDK_SWIFT_H
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wgcc-compat"

#if !defined(__has_include)
# define __has_include(x) 0
#endif
#if !defined(__has_attribute)
# define __has_attribute(x) 0
#endif
#if !defined(__has_feature)
# define __has_feature(x) 0
#endif
#if !defined(__has_warning)
# define __has_warning(x) 0
#endif

#if __has_include(<swift/objc-prologue.h>)
# include <swift/objc-prologue.h>
#endif

#pragma clang diagnostic ignored "-Wauto-import"
#if defined(__OBJC__)
#include <Foundation/Foundation.h>
#endif
#if defined(__cplusplus)
#include <cstdint>
#include <cstddef>
#include <cstdbool>
#include <cstring>
#include <stdlib.h>
#include <new>
#include <type_traits>
#else
#include <stdint.h>
#include <stddef.h>
#include <stdbool.h>
#include <string.h>
#endif
#if defined(__cplusplus)
#if defined(__arm64e__) && __has_include(<ptrauth.h>)
# include <ptrauth.h>
#else
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wreserved-macro-identifier"
# ifndef __ptrauth_swift_value_witness_function_pointer
#  define __ptrauth_swift_value_witness_function_pointer(x)
# endif
# ifndef __ptrauth_swift_class_method_pointer
#  define __ptrauth_swift_class_method_pointer(x)
# endif
#pragma clang diagnostic pop
#endif
#endif

#if !defined(SWIFT_TYPEDEFS)
# define SWIFT_TYPEDEFS 1
# if __has_include(<uchar.h>)
#  include <uchar.h>
# elif !defined(__cplusplus)
typedef uint_least16_t char16_t;
typedef uint_least32_t char32_t;
# endif
typedef float swift_float2  __attribute__((__ext_vector_type__(2)));
typedef float swift_float3  __attribute__((__ext_vector_type__(3)));
typedef float swift_float4  __attribute__((__ext_vector_type__(4)));
typedef double swift_double2  __attribute__((__ext_vector_type__(2)));
typedef double swift_double3  __attribute__((__ext_vector_type__(3)));
typedef double swift_double4  __attribute__((__ext_vector_type__(4)));
typedef int swift_int2  __attribute__((__ext_vector_type__(2)));
typedef int swift_int3  __attribute__((__ext_vector_type__(3)));
typedef int swift_int4  __attribute__((__ext_vector_type__(4)));
typedef unsigned int swift_uint2  __attribute__((__ext_vector_type__(2)));
typedef unsigned int swift_uint3  __attribute__((__ext_vector_type__(3)));
typedef unsigned int swift_uint4  __attribute__((__ext_vector_type__(4)));
#endif

#if !defined(SWIFT_PASTE)
# define SWIFT_PASTE_HELPER(x, y) x##y
# define SWIFT_PASTE(x, y) SWIFT_PASTE_HELPER(x, y)
#endif
#if !defined(SWIFT_METATYPE)
# define SWIFT_METATYPE(X) Class
#endif
#if !defined(SWIFT_CLASS_PROPERTY)
# if __has_feature(objc_class_property)
#  define SWIFT_CLASS_PROPERTY(...) __VA_ARGS__
# else
#  define SWIFT_CLASS_PROPERTY(...) 
# endif
#endif
#if !defined(SWIFT_RUNTIME_NAME)
# if __has_attribute(objc_runtime_name)
#  define SWIFT_RUNTIME_NAME(X) __attribute__((objc_runtime_name(X)))
# else
#  define SWIFT_RUNTIME_NAME(X) 
# endif
#endif
#if !defined(SWIFT_COMPILE_NAME)
# if __has_attribute(swift_name)
#  define SWIFT_COMPILE_NAME(X) __attribute__((swift_name(X)))
# else
#  define SWIFT_COMPILE_NAME(X) 
# endif
#endif
#if !defined(SWIFT_METHOD_FAMILY)
# if __has_attribute(objc_method_family)
#  define SWIFT_METHOD_FAMILY(X) __attribute__((objc_method_family(X)))
# else
#  define SWIFT_METHOD_FAMILY(X) 
# endif
#endif
#if !defined(SWIFT_NOESCAPE)
# if __has_attribute(noescape)
#  define SWIFT_NOESCAPE __attribute__((noescape))
# else
#  define SWIFT_NOESCAPE 
# endif
#endif
#if !defined(SWIFT_RELEASES_ARGUMENT)
# if __has_attribute(ns_consumed)
#  define SWIFT_RELEASES_ARGUMENT __attribute__((ns_consumed))
# else
#  define SWIFT_RELEASES_ARGUMENT 
# endif
#endif
#if !defined(SWIFT_WARN_UNUSED_RESULT)
# if __has_attribute(warn_unused_result)
#  define SWIFT_WARN_UNUSED_RESULT __attribute__((warn_unused_result))
# else
#  define SWIFT_WARN_UNUSED_RESULT 
# endif
#endif
#if !defined(SWIFT_NORETURN)
# if __has_attribute(noreturn)
#  define SWIFT_NORETURN __attribute__((noreturn))
# else
#  define SWIFT_NORETURN 
# endif
#endif
#if !defined(SWIFT_CLASS_EXTRA)
# define SWIFT_CLASS_EXTRA 
#endif
#if !defined(SWIFT_PROTOCOL_EXTRA)
# define SWIFT_PROTOCOL_EXTRA 
#endif
#if !defined(SWIFT_ENUM_EXTRA)
# define SWIFT_ENUM_EXTRA 
#endif
#if !defined(SWIFT_CLASS)
# if __has_attribute(objc_subclassing_restricted)
#  define SWIFT_CLASS(SWIFT_NAME) SWIFT_RUNTIME_NAME(SWIFT_NAME) __attribute__((objc_subclassing_restricted)) SWIFT_CLASS_EXTRA
#  define SWIFT_CLASS_NAMED(SWIFT_NAME) __attribute__((objc_subclassing_restricted)) SWIFT_COMPILE_NAME(SWIFT_NAME) SWIFT_CLASS_EXTRA
# else
#  define SWIFT_CLASS(SWIFT_NAME) SWIFT_RUNTIME_NAME(SWIFT_NAME) SWIFT_CLASS_EXTRA
#  define SWIFT_CLASS_NAMED(SWIFT_NAME) SWIFT_COMPILE_NAME(SWIFT_NAME) SWIFT_CLASS_EXTRA
# endif
#endif
#if !defined(SWIFT_RESILIENT_CLASS)
# if __has_attribute(objc_class_stub)
#  define SWIFT_RESILIENT_CLASS(SWIFT_NAME) SWIFT_CLASS(SWIFT_NAME) __attribute__((objc_class_stub))
#  define SWIFT_RESILIENT_CLASS_NAMED(SWIFT_NAME) __attribute__((objc_class_stub)) SWIFT_CLASS_NAMED(SWIFT_NAME)
# else
#  define SWIFT_RESILIENT_CLASS(SWIFT_NAME) SWIFT_CLASS(SWIFT_NAME)
#  define SWIFT_RESILIENT_CLASS_NAMED(SWIFT_NAME) SWIFT_CLASS_NAMED(SWIFT_NAME)
# endif
#endif
#if !defined(SWIFT_PROTOCOL)
# define SWIFT_PROTOCOL(SWIFT_NAME) SWIFT_RUNTIME_NAME(SWIFT_NAME) SWIFT_PROTOCOL_EXTRA
# define SWIFT_PROTOCOL_NAMED(SWIFT_NAME) SWIFT_COMPILE_NAME(SWIFT_NAME) SWIFT_PROTOCOL_EXTRA
#endif
#if !defined(SWIFT_EXTENSION)
# define SWIFT_EXTENSION(M) SWIFT_PASTE(M##_Swift_, __LINE__)
#endif
#if !defined(OBJC_DESIGNATED_INITIALIZER)
# if __has_attribute(objc_designated_initializer)
#  define OBJC_DESIGNATED_INITIALIZER __attribute__((objc_designated_initializer))
# else
#  define OBJC_DESIGNATED_INITIALIZER 
# endif
#endif
#if !defined(SWIFT_ENUM_ATTR)
# if __has_attribute(enum_extensibility)
#  define SWIFT_ENUM_ATTR(_extensibility) __attribute__((enum_extensibility(_extensibility)))
# else
#  define SWIFT_ENUM_ATTR(_extensibility) 
# endif
#endif
#if !defined(SWIFT_ENUM)
# define SWIFT_ENUM(_type, _name, _extensibility) enum _name : _type _name; enum SWIFT_ENUM_ATTR(_extensibility) SWIFT_ENUM_EXTRA _name : _type
# if __has_feature(generalized_swift_name)
#  define SWIFT_ENUM_NAMED(_type, _name, SWIFT_NAME, _extensibility) enum _name : _type _name SWIFT_COMPILE_NAME(SWIFT_NAME); enum SWIFT_COMPILE_NAME(SWIFT_NAME) SWIFT_ENUM_ATTR(_extensibility) SWIFT_ENUM_EXTRA _name : _type
# else
#  define SWIFT_ENUM_NAMED(_type, _name, SWIFT_NAME, _extensibility) SWIFT_ENUM(_type, _name, _extensibility)
# endif
#endif
#if !defined(SWIFT_UNAVAILABLE)
# define SWIFT_UNAVAILABLE __attribute__((unavailable))
#endif
#if !defined(SWIFT_UNAVAILABLE_MSG)
# define SWIFT_UNAVAILABLE_MSG(msg) __attribute__((unavailable(msg)))
#endif
#if !defined(SWIFT_AVAILABILITY)
# define SWIFT_AVAILABILITY(plat, ...) __attribute__((availability(plat, __VA_ARGS__)))
#endif
#if !defined(SWIFT_WEAK_IMPORT)
# define SWIFT_WEAK_IMPORT __attribute__((weak_import))
#endif
#if !defined(SWIFT_DEPRECATED)
# define SWIFT_DEPRECATED __attribute__((deprecated))
#endif
#if !defined(SWIFT_DEPRECATED_MSG)
# define SWIFT_DEPRECATED_MSG(...) __attribute__((deprecated(__VA_ARGS__)))
#endif
#if !defined(SWIFT_DEPRECATED_OBJC)
# if __has_feature(attribute_diagnose_if_objc)
#  define SWIFT_DEPRECATED_OBJC(Msg) __attribute__((diagnose_if(1, Msg, "warning")))
# else
#  define SWIFT_DEPRECATED_OBJC(Msg) SWIFT_DEPRECATED_MSG(Msg)
# endif
#endif
#if defined(__OBJC__)
#if !defined(IBSegueAction)
# define IBSegueAction 
#endif
#endif
#if !defined(SWIFT_EXTERN)
# if defined(__cplusplus)
#  define SWIFT_EXTERN extern "C"
# else
#  define SWIFT_EXTERN extern
# endif
#endif
#if !defined(SWIFT_CALL)
# define SWIFT_CALL __attribute__((swiftcall))
#endif
#if !defined(SWIFT_INDIRECT_RESULT)
# define SWIFT_INDIRECT_RESULT __attribute__((swift_indirect_result))
#endif
#if !defined(SWIFT_CONTEXT)
# define SWIFT_CONTEXT __attribute__((swift_context))
#endif
#if !defined(SWIFT_ERROR_RESULT)
# define SWIFT_ERROR_RESULT __attribute__((swift_error_result))
#endif
#if defined(__cplusplus)
# define SWIFT_NOEXCEPT noexcept
#else
# define SWIFT_NOEXCEPT 
#endif
#if !defined(SWIFT_C_INLINE_THUNK)
# if __has_attribute(always_inline)
# if __has_attribute(nodebug)
#  define SWIFT_C_INLINE_THUNK inline __attribute__((always_inline)) __attribute__((nodebug))
# else
#  define SWIFT_C_INLINE_THUNK inline __attribute__((always_inline))
# endif
# else
#  define SWIFT_C_INLINE_THUNK inline
# endif
#endif
#if defined(_WIN32)
#if !defined(SWIFT_IMPORT_STDLIB_SYMBOL)
# define SWIFT_IMPORT_STDLIB_SYMBOL __declspec(dllimport)
#endif
#else
#if !defined(SWIFT_IMPORT_STDLIB_SYMBOL)
# define SWIFT_IMPORT_STDLIB_SYMBOL 
#endif
#endif
#if defined(__OBJC__)
#if __has_feature(objc_modules)
#if __has_warning("-Watimport-in-framework-header")
#pragma clang diagnostic ignored "-Watimport-in-framework-header"
#endif
@import CoreFoundation;
@import Foundation;
@import OMSDK_Loopme;
@import ObjectiveC;
#endif

#endif
#pragma clang diagnostic ignored "-Wproperty-attribute-mismatch"
#pragma clang diagnostic ignored "-Wduplicate-method-arg"
#if __has_warning("-Wpragma-clang-attribute")
# pragma clang diagnostic ignored "-Wpragma-clang-attribute"
#endif
#pragma clang diagnostic ignored "-Wunknown-pragmas"
#pragma clang diagnostic ignored "-Wnullability"
#pragma clang diagnostic ignored "-Wdollar-in-identifier-extension"

#if __has_attribute(external_source_symbol)
# pragma push_macro("any")
# undef any
# pragma clang attribute push(__attribute__((external_source_symbol(language="Swift", defined_in="LoopMeUnitedSDK",generated_declaration))), apply_to=any(function,enum,objc_interface,objc_category,objc_protocol))
# pragma pop_macro("any")
#endif

#if defined(__OBJC__)
@class NSString;
enum LoopMeAdOrientation : NSInteger;
enum LoopMeCreativeType : NSInteger;
@class NSNumber;
@class LoopMeMRAIDExpandProperties;
@class LoopMeVastProperties;
enum LoopMeTrackerName : NSInteger;

SWIFT_CLASS_NAMED("AdConfigurationWrapper")
@interface LoopMeAdConfiguration : NSObject
@property (nonatomic, copy) NSString * _Nonnull appKey;
@property (nonatomic, readonly, copy) NSString * _Nonnull adId;
@property (nonatomic, readonly) BOOL isV360;
@property (nonatomic, readonly) BOOL debug;
@property (nonatomic, readonly) BOOL preload25;
@property (nonatomic) enum LoopMeAdOrientation adOrientation;
@property (nonatomic, readonly) enum LoopMeCreativeType creativeType;
@property (nonatomic, copy) NSString * _Nonnull creativeContent;
@property (nonatomic, readonly) BOOL isPortrait;
@property (nonatomic, readonly, copy) NSDictionary<NSString *, id> * _Nonnull adIdsForMoat;
@property (nonatomic, readonly, copy) NSDictionary<NSString *, id> * _Nonnull adIdsForIAS;
@property (nonatomic, readonly, copy) NSString * _Nullable skadSignature;
@property (nonatomic, readonly, copy) NSString * _Nullable skadNonce;
@property (nonatomic, readonly, copy) NSString * _Nullable skadNetwork;
@property (nonatomic, readonly, copy) NSString * _Nullable skadVersion;
@property (nonatomic, readonly, strong) NSNumber * _Nullable skadTimestamp;
@property (nonatomic, readonly, strong) NSNumber * _Nullable skadSourceApp;
@property (nonatomic, readonly, strong) NSNumber * _Nullable skadItunesitem;
@property (nonatomic, readonly, strong) NSNumber * _Nullable skadCampaign;
@property (nonatomic, readonly, strong) NSNumber * _Nullable skadSourceidentifier;
@property (nonatomic, strong) LoopMeMRAIDExpandProperties * _Nullable expandProperties;
@property (nonatomic, strong) LoopMeVastProperties * _Nullable vastProperties;
@property (nonatomic) BOOL allowOrientationChange;
- (BOOL)useTracking:(enum LoopMeTrackerName)trackerNameWrapped SWIFT_WARN_UNUSED_RESULT;
- (nonnull instancetype)init SWIFT_UNAVAILABLE;
+ (nonnull instancetype)new SWIFT_UNAVAILABLE_MSG("-init is unavailable");
@end

typedef SWIFT_ENUM_NAMED(NSInteger, LoopMeAdOrientation, "AdOrientationWrapper", open) {
  LoopMeAdOrientationUndefined = 0,
  LoopMeAdOrientationPortrait = 1,
  LoopMeAdOrientationLandscape = 2,
};

@class OMIDLoopmeAdSessionContext;

SWIFT_CLASS("_TtC15LoopMeUnitedSDK22AdSessionContextResult")
@interface AdSessionContextResult : NSObject
@property (nonatomic, strong) OMIDLoopmeAdSessionContext * _Nullable context;
@property (nonatomic) NSError * _Nullable error;
- (nonnull instancetype)initWithContext:(OMIDLoopmeAdSessionContext * _Nullable)context error:(NSError * _Nullable)error OBJC_DESIGNATED_INITIALIZER;
- (nonnull instancetype)init SWIFT_UNAVAILABLE;
+ (nonnull instancetype)new SWIFT_UNAVAILABLE_MSG("-init is unavailable");
@end

@class LoopMeViewableImpression;
@class LoopMeLinearTracking;

SWIFT_CLASS_NAMED("AdTrackingLinksWrapper")
@interface LoopMeAdTrackingLinks : NSObject
@property (nonatomic, readonly, copy) NSSet<NSString *> * _Nonnull errorTemplates;
@property (nonatomic, readonly, copy) NSSet<NSString *> * _Nonnull impression;
@property (nonatomic, readonly, copy) NSString * _Nonnull clickVideo;
@property (nonatomic, readonly, copy) NSString * _Nonnull clickCompanion;
@property (nonatomic, readonly, strong) LoopMeViewableImpression * _Nonnull viewableImpression;
@property (nonatomic, readonly, strong) LoopMeLinearTracking * _Nonnull linear;
- (nonnull instancetype)init SWIFT_UNAVAILABLE;
+ (nonnull instancetype)new SWIFT_UNAVAILABLE_MSG("-init is unavailable");
@end


SWIFT_CLASS_NAMED("AdVerificationWrapper")
@interface LoopMeAdVerification : NSObject
@property (nonatomic, readonly, copy) NSString * _Nonnull vendor;
@property (nonatomic, readonly, copy) NSString * _Nonnull jsResource;
@property (nonatomic, readonly, copy) NSString * _Nonnull verificationParameters;
- (nonnull instancetype)init SWIFT_UNAVAILABLE;
+ (nonnull instancetype)new SWIFT_UNAVAILABLE_MSG("-init is unavailable");
@end


SWIFT_CLASS_NAMED("AssetLinksWrapper")
@interface LoopMeAssetLinks : NSObject
@property (nonatomic, readonly, copy) NSArray<NSString *> * _Nonnull videoURL;
@property (nonatomic, readonly, copy) NSString * _Nonnull vpaidURL;
@property (nonatomic, readonly, copy) NSString * _Nonnull adParameters;
@property (nonatomic, readonly, copy) NSArray<NSString *> * _Nonnull endCard;
- (nonnull instancetype)init SWIFT_UNAVAILABLE;
+ (nonnull instancetype)new SWIFT_UNAVAILABLE_MSG("-init is unavailable");
@end


SWIFT_CLASS_NAMED("CCPATools")
@interface LoopMeCCPATools : NSObject
SWIFT_CLASS_PROPERTY(@property (nonatomic, class, copy) NSString * _Nonnull ccpaString;)
+ (NSString * _Nonnull)ccpaString SWIFT_WARN_UNUSED_RESULT;
+ (void)setCcpaString:(NSString * _Nonnull)newValue;
- (nonnull instancetype)init OBJC_DESIGNATED_INITIALIZER;
@end


SWIFT_CLASS_NAMED("CoppaTools")
@interface LoopMeCOPPATools : NSObject
SWIFT_CLASS_PROPERTY(@property (nonatomic, class) BOOL coppa;)
+ (BOOL)coppa SWIFT_WARN_UNUSED_RESULT;
+ (void)setCoppa:(BOOL)value;
- (nonnull instancetype)init OBJC_DESIGNATED_INITIALIZER;
@end

typedef SWIFT_ENUM_NAMED(NSInteger, LoopMeCreativeType, "CreativeTypeWrapper", open) {
  LoopMeCreativeTypeVpaid = 0,
  LoopMeCreativeTypeVast = 1,
  LoopMeCreativeTypeNormal = 2,
  LoopMeCreativeTypeMraid = 3,
};


SWIFT_CLASS_NAMED("LinearTrackingWrapper")
@interface LoopMeLinearTracking : NSObject
- (nonnull instancetype)init SWIFT_UNAVAILABLE;
+ (nonnull instancetype)new SWIFT_UNAVAILABLE_MSG("-init is unavailable");
@end

@class LoopMeServerCommunicator;

SWIFT_PROTOCOL("_TtP15LoopMeUnitedSDK32LoopMeServerCommunicatorDelegate_")
@protocol LoopMeServerCommunicatorDelegate <NSObject>
- (void)serverCommunicator:(LoopMeServerCommunicator * _Nonnull)communicator didReceive:(LoopMeAdConfiguration * _Nonnull)adConfiguration;
- (void)serverCommunicator:(LoopMeServerCommunicator * _Nonnull)communicator didFailWith:(NSError * _Nullable)error;
- (void)serverCommunicatorDidReceiveAd:(LoopMeServerCommunicator * _Nonnull)communicator;
@end


SWIFT_CLASS_NAMED("MRAIDExpandPropertiesWrapper")
@interface LoopMeMRAIDExpandProperties : NSObject
- (nonnull instancetype)init OBJC_DESIGNATED_INITIALIZER;
@property (nonatomic) float width;
@property (nonatomic) float height;
@property (nonatomic) BOOL useCustomClose;
@end

@class OMIDLoopmeAdSession;
@class OMIDLoopmeVASTProperties;

SWIFT_CLASS_NAMED("OMIDVideoEventsWrapper")
@interface LoopMeOMIDVideoEventsWrapper : NSObject
- (nullable instancetype)initWithSession:(OMIDLoopmeAdSession * _Nonnull)session error:(NSError * _Nullable * _Nullable)error OBJC_DESIGNATED_INITIALIZER;
- (void)loadedWith:(OMIDLoopmeVASTProperties * _Nonnull)vastProperties;
- (void)startWithDuration:(CGFloat)duration videoPlayerVolume:(CGFloat)videoPlayerVolume;
- (void)firstQuartile;
- (void)midpoint;
- (void)thirdQuartile;
- (void)complete;
- (void)pause;
- (void)resume;
- (void)skipped;
- (void)volumeChangeTo:(CGFloat)playerVolume;
- (void)adUserInteractionWithType:(OMIDInteractionType)interactionType;
- (nonnull instancetype)init SWIFT_UNAVAILABLE;
+ (nonnull instancetype)new SWIFT_UNAVAILABLE_MSG("-init is unavailable");
@end

@class WKWebView;
@class OMIDLoopmeVerificationScriptResource;
@class OMIDLoopmeAdSessionConfiguration;

SWIFT_CLASS_NAMED("OMSDKWrapper")
@interface LoopMeOMIDWrapper : NSObject
+ (BOOL)initOMIDWithCompletionBlock:(void (^ _Nonnull)(BOOL))completionBlock SWIFT_METHOD_FAMILY(none) SWIFT_WARN_UNUSED_RESULT;
- (NSString * _Nullable)injectScriptContentIntoHTML:(NSString * _Nonnull)htmlString error:(NSError * _Nullable * _Nullable)error SWIFT_WARN_UNUSED_RESULT;
- (OMIDLoopmeAdSessionContext * _Nullable)contextForHTML:(WKWebView * _Nonnull)webView error:(NSError * _Nullable * _Nullable)error SWIFT_WARN_UNUSED_RESULT;
- (AdSessionContextResult * _Nonnull)contextForNativeVideo:(NSArray<LoopMeAdVerification *> * _Nonnull)resources SWIFT_WARN_UNUSED_RESULT;
- (NSArray<OMIDLoopmeVerificationScriptResource *> * _Nonnull)toOmidResources:(NSArray<LoopMeAdVerification *> * _Nonnull)resources SWIFT_WARN_UNUSED_RESULT;
- (OMIDLoopmeAdSessionConfiguration * _Nullable)configurationFor:(OMIDCreativeType)creativeType error:(NSError * _Nullable * _Nullable)error SWIFT_WARN_UNUSED_RESULT;
- (OMIDLoopmeAdSession * _Nullable)sessionFor:(OMIDLoopmeAdSessionConfiguration * _Nonnull)configuration context:(OMIDLoopmeAdSessionContext * _Nonnull)context error:(NSError * _Nullable * _Nullable)error SWIFT_WARN_UNUSED_RESULT;
- (OMIDLoopmeAdSession * _Nullable)sessionForHTML:(WKWebView * _Nonnull)webView error:(NSError * _Nullable * _Nullable)error SWIFT_WARN_UNUSED_RESULT;
- (OMIDLoopmeAdSession * _Nullable)sessionForNativeVideo:(NSArray<LoopMeAdVerification *> * _Nonnull)resources error:(NSError * _Nullable * _Nullable)error SWIFT_WARN_UNUSED_RESULT;
- (nonnull instancetype)init OBJC_DESIGNATED_INITIALIZER;
@end


SWIFT_CLASS_NAMED("ProgressEventTrackerWrapper")
@interface LoopMeProgressEventTracker : NSObject
- (nonnull instancetype)init SWIFT_UNAVAILABLE;
+ (nonnull instancetype)new SWIFT_UNAVAILABLE_MSG("-init is unavailable");
@end


SWIFT_CLASS_NAMED("ProgressEventWrappper")
@interface LoopMeProgressEvent : NSObject
- (nonnull instancetype)init SWIFT_UNAVAILABLE;
+ (nonnull instancetype)new SWIFT_UNAVAILABLE_MSG("-init is unavailable");
@end


SWIFT_CLASS("_TtC15LoopMeUnitedSDK10SDKUtility")
@interface SDKUtility : NSObject
+ (NSString * _Nonnull)loopmeSDKVersionString SWIFT_WARN_UNUSED_RESULT;
- (nonnull instancetype)init OBJC_DESIGNATED_INITIALIZER;
@end

@class NSURL;
@class NSData;

SWIFT_CLASS_NAMED("ServerCommunicator")
@interface LoopMeServerCommunicator : NSObject
@property (nonatomic, copy) NSString * _Nullable appKey;
- (nonnull instancetype)initWithDelegate:(id <LoopMeServerCommunicatorDelegate> _Nullable)delegate OBJC_DESIGNATED_INITIALIZER;
- (void)loadWithUrl:(NSURL * _Nonnull)url requestBody:(NSData * _Nullable)requestBody method:(NSString * _Nullable)method;
- (void)cancel;
- (nonnull instancetype)init SWIFT_UNAVAILABLE;
+ (nonnull instancetype)new SWIFT_UNAVAILABLE_MSG("-init is unavailable");
@end

typedef SWIFT_ENUM_NAMED(NSInteger, LoopMeTimeOffsetType, "TimeOffsetType", open) {
  LoopMeTimeOffsetTypePercent = 0,
  LoopMeTimeOffsetTypeSeconds = 1,
};

typedef SWIFT_ENUM_NAMED(NSInteger, LoopMeTrackerName, "TrackerNameWrapper", open) {
  LoopMeTrackerNameIas = 0,
  LoopMeTrackerNameMoat = 1,
};


SWIFT_CLASS("_TtC15LoopMeUnitedSDK9UserAgent")
@interface UserAgent : NSObject
SWIFT_CLASS_PROPERTY(@property (nonatomic, class, readonly, copy) NSString * _Nonnull defaultUserAgent;)
+ (NSString * _Nonnull)defaultUserAgent SWIFT_WARN_UNUSED_RESULT;
- (nonnull instancetype)init OBJC_DESIGNATED_INITIALIZER;
@end

typedef SWIFT_ENUM_NAMED(NSInteger, LoopMeVASTEventType, "VASTEventType", open) {
  LoopMeVASTEventTypeImpression = 0,
  LoopMeVASTEventTypeLinearStart = 1,
  LoopMeVASTEventTypeLinearFirstQuartile = 2,
  LoopMeVASTEventTypeLinearMidpoint = 3,
  LoopMeVASTEventTypeLinearThirdQuartile = 4,
  LoopMeVASTEventTypeLinearComplete = 5,
  LoopMeVASTEventTypeLinearClose = 6,
  LoopMeVASTEventTypeLinearPause = 7,
  LoopMeVASTEventTypeLinearResume = 8,
  LoopMeVASTEventTypeLinearExpand = 9,
  LoopMeVASTEventTypeLinearCollapse = 10,
  LoopMeVASTEventTypeLinearSkip = 11,
  LoopMeVASTEventTypeLinearMute = 12,
  LoopMeVASTEventTypeLinearUnmute = 13,
  LoopMeVASTEventTypeLinearProgress = 14,
  LoopMeVASTEventTypeLinearClickTracking = 15,
  LoopMeVASTEventTypeCompanionCreativeView = 16,
  LoopMeVASTEventTypeCompanionClickTracking = 17,
  LoopMeVASTEventTypeViewable = 18,
  LoopMeVASTEventTypeNotViewable = 19,
  LoopMeVASTEventTypeViewUndetermined = 20,
};


SWIFT_CLASS_NAMED("VastEventTrackerWrapper")
@interface LoopMeVASTEventTracker : NSObject
- (nonnull instancetype)initWithTrackingLinks:(LoopMeAdTrackingLinks * _Nonnull)trackingLinks OBJC_DESIGNATED_INITIALIZER;
- (void)trackEvent:(enum LoopMeVASTEventType)event;
- (void)trackErrorCode:(NSInteger)code;
- (void)trackAdVerificationNonExecuted;
- (void)setCurrentTime:(NSTimeInterval)currentTime;
- (nonnull instancetype)init SWIFT_UNAVAILABLE;
+ (nonnull instancetype)new SWIFT_UNAVAILABLE_MSG("-init is unavailable");
@end


SWIFT_CLASS("_TtC15LoopMeUnitedSDK14VastProperties")
@interface VastProperties : NSObject
- (nonnull instancetype)init OBJC_DESIGNATED_INITIALIZER;
@end

@class NSXMLParser;

@interface VastProperties (SWIFT_EXTENSION(LoopMeUnitedSDK)) <NSXMLParserDelegate>
- (void)parser:(NSXMLParser * _Nonnull)parser didStartElement:(NSString * _Nonnull)elementName namespaceURI:(NSString * _Nullable)namespaceURI qualifiedName:(NSString * _Nullable)qName attributes:(NSDictionary<NSString *, NSString *> * _Nonnull)attributeDict;
- (void)parser:(NSXMLParser * _Nonnull)parser didEndElement:(NSString * _Nonnull)elementName namespaceURI:(NSString * _Nullable)namespaceURI qualifiedName:(NSString * _Nullable)qName;
- (void)parser:(NSXMLParser * _Nonnull)parser foundCDATA:(NSData * _Nonnull)CDATABlock;
- (void)parser:(NSXMLParser * _Nonnull)parser foundCharacters:(NSString * _Nonnull)string;
- (void)parser:(NSXMLParser * _Nonnull)parser validationErrorOccurred:(NSError * _Nonnull)validationError;
@end

@class LoopMeVastSkipOffset;

SWIFT_CLASS_NAMED("VastPropertiesWrapper")
@interface LoopMeVastProperties : NSObject
@property (nonatomic, readonly, copy) NSString * _Nullable adId;
@property (nonatomic, readonly) NSTimeInterval duration;
@property (nonatomic, readonly, strong) LoopMeVastSkipOffset * _Nonnull skipOffset;
@property (nonatomic, readonly, strong) LoopMeAdTrackingLinks * _Nonnull trackingLinks;
@property (nonatomic, readonly, strong) LoopMeAssetLinks * _Nonnull assetLinks;
@property (nonatomic, readonly, copy) NSArray<LoopMeAdVerification *> * _Nonnull adVerifications;
@property (nonatomic, readonly) BOOL isVpaid;
- (nonnull instancetype)init SWIFT_UNAVAILABLE;
+ (nonnull instancetype)new SWIFT_UNAVAILABLE_MSG("-init is unavailable");
@end


SWIFT_CLASS_NAMED("VastSkipOffsetWrapper")
@interface LoopMeVastSkipOffset : NSObject
@property (nonatomic, readonly) double value;
@property (nonatomic, readonly) enum LoopMeTimeOffsetType type;
- (nonnull instancetype)init SWIFT_UNAVAILABLE;
+ (nonnull instancetype)new SWIFT_UNAVAILABLE_MSG("-init is unavailable");
@end


SWIFT_CLASS_NAMED("ViewableImpressionWrapper")
@interface LoopMeViewableImpression : NSObject
- (nonnull instancetype)init SWIFT_UNAVAILABLE;
+ (nonnull instancetype)new SWIFT_UNAVAILABLE_MSG("-init is unavailable");
@end

#endif
#if __has_attribute(external_source_symbol)
# pragma clang attribute pop
#endif
#if defined(__cplusplus)
#endif
#pragma clang diagnostic pop
#endif

#else
#error unsupported Swift architecture
#endif
