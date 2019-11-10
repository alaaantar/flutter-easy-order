//
//  Generated file. Do not edit.
//

#import "GeneratedPluginRegistrant.h"
#import <cloud_firestore/CloudFirestorePlugin.h>
#import <firebase_analytics/FirebaseAnalyticsPlugin.h>
#import <firebase_auth/FirebaseAuthPlugin.h>
#import <firebase_core/FirebaseCorePlugin.h>
#import <firebase_crashlytics/FirebaseCrashlyticsPlugin.h>
#import <firebase_performance/FirebasePerformancePlugin.h>
#import <firebase_storage/FirebaseStoragePlugin.h>
#import <flutter_facebook_login/FacebookLoginPlugin.h>
#import <google_sign_in/GoogleSignInPlugin.h>
#import <image_picker/ImagePickerPlugin.h>
#import <path_provider/PathProviderPlugin.h>
#import <shared_preferences/SharedPreferencesPlugin.h>
#import <url_launcher/UrlLauncherPlugin.h>

@implementation GeneratedPluginRegistrant

+ (void)registerWithRegistry:(NSObject<FlutterPluginRegistry>*)registry {
  [FLTCloudFirestorePlugin registerWithRegistrar:[registry registrarForPlugin:@"FLTCloudFirestorePlugin"]];
  [FLTFirebaseAnalyticsPlugin registerWithRegistrar:[registry registrarForPlugin:@"FLTFirebaseAnalyticsPlugin"]];
  [FLTFirebaseAuthPlugin registerWithRegistrar:[registry registrarForPlugin:@"FLTFirebaseAuthPlugin"]];
  [FLTFirebaseCorePlugin registerWithRegistrar:[registry registrarForPlugin:@"FLTFirebaseCorePlugin"]];
  [FirebaseCrashlyticsPlugin registerWithRegistrar:[registry registrarForPlugin:@"FirebaseCrashlyticsPlugin"]];
  [FLTFirebasePerformancePlugin registerWithRegistrar:[registry registrarForPlugin:@"FLTFirebasePerformancePlugin"]];
  [FLTFirebaseStoragePlugin registerWithRegistrar:[registry registrarForPlugin:@"FLTFirebaseStoragePlugin"]];
  [FacebookLoginPlugin registerWithRegistrar:[registry registrarForPlugin:@"FacebookLoginPlugin"]];
  [FLTGoogleSignInPlugin registerWithRegistrar:[registry registrarForPlugin:@"FLTGoogleSignInPlugin"]];
  [FLTImagePickerPlugin registerWithRegistrar:[registry registrarForPlugin:@"FLTImagePickerPlugin"]];
  [FLTPathProviderPlugin registerWithRegistrar:[registry registrarForPlugin:@"FLTPathProviderPlugin"]];
  [FLTSharedPreferencesPlugin registerWithRegistrar:[registry registrarForPlugin:@"FLTSharedPreferencesPlugin"]];
  [FLTUrlLauncherPlugin registerWithRegistrar:[registry registrarForPlugin:@"FLTUrlLauncherPlugin"]];
}

@end
