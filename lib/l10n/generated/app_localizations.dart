import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
  ];

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @deleteData.
  ///
  /// In en, this message translates to:
  /// **'Delete Data'**
  String get deleteData;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @history.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get history;

  /// No description provided for @progress.
  ///
  /// In en, this message translates to:
  /// **'Progress'**
  String get progress;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @spanish.
  ///
  /// In en, this message translates to:
  /// **'Spanish'**
  String get spanish;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @updateProfilePicture.
  ///
  /// In en, this message translates to:
  /// **'Update Profile Picture'**
  String get updateProfilePicture;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @todaysTasks.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Tasks'**
  String get todaysTasks;

  /// No description provided for @logDay.
  ///
  /// In en, this message translates to:
  /// **'Log Day'**
  String get logDay;

  /// No description provided for @logged.
  ///
  /// In en, this message translates to:
  /// **'Logged'**
  String get logged;

  /// No description provided for @pending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get pending;

  /// No description provided for @macros.
  ///
  /// In en, this message translates to:
  /// **'Macros'**
  String get macros;

  /// No description provided for @measurements.
  ///
  /// In en, this message translates to:
  /// **'Measurements'**
  String get measurements;

  /// No description provided for @recorded.
  ///
  /// In en, this message translates to:
  /// **'Recorded'**
  String get recorded;

  /// No description provided for @notRecorded.
  ///
  /// In en, this message translates to:
  /// **'Not recorded'**
  String get notRecorded;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @greatJob.
  ///
  /// In en, this message translates to:
  /// **'Great job!'**
  String get greatJob;

  /// No description provided for @almostThere.
  ///
  /// In en, this message translates to:
  /// **'Almost there!'**
  String get almostThere;

  /// No description provided for @dailyGoalReached.
  ///
  /// In en, this message translates to:
  /// **'You have reached your daily goal.'**
  String get dailyGoalReached;

  /// No description provided for @completeOneMoreTask.
  ///
  /// In en, this message translates to:
  /// **'Complete 1 more task to reach your goal.'**
  String get completeOneMoreTask;

  /// No description provided for @dailyGoal.
  ///
  /// In en, this message translates to:
  /// **'DAILY GOAL'**
  String get dailyGoal;

  /// No description provided for @tasksRemaining.
  ///
  /// In en, this message translates to:
  /// **'{count} of {total} tasks remaining'**
  String tasksRemaining(int count, int total);

  /// No description provided for @facePhoto.
  ///
  /// In en, this message translates to:
  /// **'Face Photo'**
  String get facePhoto;

  /// No description provided for @bodyFrontPhoto.
  ///
  /// In en, this message translates to:
  /// **'Body Front Photo'**
  String get bodyFrontPhoto;

  /// No description provided for @bodySidePhoto.
  ///
  /// In en, this message translates to:
  /// **'Body Side Photo'**
  String get bodySidePhoto;

  /// No description provided for @bodyBackPhoto.
  ///
  /// In en, this message translates to:
  /// **'Body Back Photo'**
  String get bodyBackPhoto;

  /// No description provided for @bodyMeasurements.
  ///
  /// In en, this message translates to:
  /// **'Body Measurements'**
  String get bodyMeasurements;

  /// No description provided for @macronutrients.
  ///
  /// In en, this message translates to:
  /// **'Macronutrients'**
  String get macronutrients;

  /// No description provided for @capturedAt.
  ///
  /// In en, this message translates to:
  /// **'Captured at {time}'**
  String capturedAt(String time);

  /// No description provided for @pendingRegistration.
  ///
  /// In en, this message translates to:
  /// **'Pending registration'**
  String get pendingRegistration;

  /// No description provided for @monday.
  ///
  /// In en, this message translates to:
  /// **'Monday'**
  String get monday;

  /// No description provided for @tuesday.
  ///
  /// In en, this message translates to:
  /// **'Tuesday'**
  String get tuesday;

  /// No description provided for @wednesday.
  ///
  /// In en, this message translates to:
  /// **'Wednesday'**
  String get wednesday;

  /// No description provided for @thursday.
  ///
  /// In en, this message translates to:
  /// **'Thursday'**
  String get thursday;

  /// No description provided for @friday.
  ///
  /// In en, this message translates to:
  /// **'Friday'**
  String get friday;

  /// No description provided for @saturday.
  ///
  /// In en, this message translates to:
  /// **'Saturday'**
  String get saturday;

  /// No description provided for @sunday.
  ///
  /// In en, this message translates to:
  /// **'Sunday'**
  String get sunday;

  /// No description provided for @january.
  ///
  /// In en, this message translates to:
  /// **'January'**
  String get january;

  /// No description provided for @february.
  ///
  /// In en, this message translates to:
  /// **'February'**
  String get february;

  /// No description provided for @march.
  ///
  /// In en, this message translates to:
  /// **'March'**
  String get march;

  /// No description provided for @april.
  ///
  /// In en, this message translates to:
  /// **'April'**
  String get april;

  /// No description provided for @may.
  ///
  /// In en, this message translates to:
  /// **'May'**
  String get may;

  /// No description provided for @june.
  ///
  /// In en, this message translates to:
  /// **'June'**
  String get june;

  /// No description provided for @july.
  ///
  /// In en, this message translates to:
  /// **'July'**
  String get july;

  /// No description provided for @august.
  ///
  /// In en, this message translates to:
  /// **'August'**
  String get august;

  /// No description provided for @september.
  ///
  /// In en, this message translates to:
  /// **'September'**
  String get september;

  /// No description provided for @october.
  ///
  /// In en, this message translates to:
  /// **'October'**
  String get october;

  /// No description provided for @november.
  ///
  /// In en, this message translates to:
  /// **'November'**
  String get november;

  /// No description provided for @december.
  ///
  /// In en, this message translates to:
  /// **'December'**
  String get december;

  /// No description provided for @changeAvatar.
  ///
  /// In en, this message translates to:
  /// **'CHANGE AVATAR'**
  String get changeAvatar;

  /// No description provided for @latestProgressImage.
  ///
  /// In en, this message translates to:
  /// **'Latest Progress Image'**
  String get latestProgressImage;

  /// No description provided for @useRecentFrontPhoto.
  ///
  /// In en, this message translates to:
  /// **'Use your most recent front body photo'**
  String get useRecentFrontPhoto;

  /// No description provided for @chooseFromGallery.
  ///
  /// In en, this message translates to:
  /// **'Choose from Gallery'**
  String get chooseFromGallery;

  /// No description provided for @pickImageFromDevice.
  ///
  /// In en, this message translates to:
  /// **'Pick an image from your device'**
  String get pickImageFromDevice;

  /// No description provided for @preview.
  ///
  /// In en, this message translates to:
  /// **'Preview'**
  String get preview;

  /// No description provided for @deleteDataTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete All Data'**
  String get deleteDataTitle;

  /// No description provided for @deleteDataWarning.
  ///
  /// In en, this message translates to:
  /// **'This action is irreversible. All your workout history, photos, and progress will be permanently deleted.'**
  String get deleteDataWarning;

  /// No description provided for @confirmDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete Everything'**
  String get confirmDelete;

  /// No description provided for @cancelDeletion.
  ///
  /// In en, this message translates to:
  /// **'No, keep my data'**
  String get cancelDeletion;

  /// No description provided for @dataDeleted.
  ///
  /// In en, this message translates to:
  /// **'Data deleted successfully'**
  String get dataDeleted;

  /// No description provided for @avatarSelection.
  ///
  /// In en, this message translates to:
  /// **'Avatar Selection'**
  String get avatarSelection;

  /// No description provided for @saveProfileChanges.
  ///
  /// In en, this message translates to:
  /// **'Save Profile Changes'**
  String get saveProfileChanges;

  /// No description provided for @syncsWithLatestBodyPhoto.
  ///
  /// In en, this message translates to:
  /// **'Syncs with your latest body photo'**
  String get syncsWithLatestBodyPhoto;

  /// No description provided for @uploadCustomPicture.
  ///
  /// In en, this message translates to:
  /// **'Upload a custom picture'**
  String get uploadCustomPicture;

  /// No description provided for @profileSettings.
  ///
  /// In en, this message translates to:
  /// **'Profile Settings'**
  String get profileSettings;

  /// No description provided for @nuclearOption.
  ///
  /// In en, this message translates to:
  /// **'Critical: Nuclear Option'**
  String get nuclearOption;

  /// No description provided for @deleteDataLongWarning.
  ///
  /// In en, this message translates to:
  /// **'This action is irreversible. All photos, logs, progress, and settings will be permanently removed from this device.'**
  String get deleteDataLongWarning;

  /// No description provided for @deleteConfirmation.
  ///
  /// In en, this message translates to:
  /// **'delete all'**
  String get deleteConfirmation;

  /// No description provided for @typeToDelete.
  ///
  /// In en, this message translates to:
  /// **'Type \"{word}\" to confirm:'**
  String typeToDelete(String word);

  /// No description provided for @dangerZone.
  ///
  /// In en, this message translates to:
  /// **'Danger Zone'**
  String get dangerZone;

  /// No description provided for @resetApplication.
  ///
  /// In en, this message translates to:
  /// **'Reset Application'**
  String get resetApplication;

  /// No description provided for @allDataCleared.
  ///
  /// In en, this message translates to:
  /// **'All data has been cleared.'**
  String get allDataCleared;

  /// No description provided for @streak.
  ///
  /// In en, this message translates to:
  /// **'Streak'**
  String get streak;

  /// No description provided for @activitySuffix.
  ///
  /// In en, this message translates to:
  /// **'Activity'**
  String get activitySuffix;

  /// No description provided for @nutrientsOverview.
  ///
  /// In en, this message translates to:
  /// **'Nutrients Overview'**
  String get nutrientsOverview;

  /// No description provided for @measurementsOverview.
  ///
  /// In en, this message translates to:
  /// **'Measurements Overview'**
  String get measurementsOverview;

  /// No description provided for @currentStreak.
  ///
  /// In en, this message translates to:
  /// **'CURRENT STREAK'**
  String get currentStreak;

  /// No description provided for @days.
  ///
  /// In en, this message translates to:
  /// **'days'**
  String get days;

  /// No description provided for @daysActive.
  ///
  /// In en, this message translates to:
  /// **'{count} days active'**
  String daysActive(int count);

  /// No description provided for @daysMissed.
  ///
  /// In en, this message translates to:
  /// **'{count} days missed'**
  String daysMissed(int count);

  /// No description provided for @avgCalories.
  ///
  /// In en, this message translates to:
  /// **'AVG CALS'**
  String get avgCalories;

  /// No description provided for @protein.
  ///
  /// In en, this message translates to:
  /// **'PROTEIN'**
  String get protein;

  /// No description provided for @carbs.
  ///
  /// In en, this message translates to:
  /// **'CARBS'**
  String get carbs;

  /// No description provided for @fats.
  ///
  /// In en, this message translates to:
  /// **'FATS'**
  String get fats;

  /// No description provided for @dailyAverage.
  ///
  /// In en, this message translates to:
  /// **'Daily average'**
  String get dailyAverage;

  /// No description provided for @latestRecorded.
  ///
  /// In en, this message translates to:
  /// **'Latest recorded'**
  String get latestRecorded;

  /// No description provided for @noMeasurementsYet.
  ///
  /// In en, this message translates to:
  /// **'No measurements recorded yet'**
  String get noMeasurementsYet;

  /// No description provided for @noRecordsDay.
  ///
  /// In en, this message translates to:
  /// **'No records for this day'**
  String get noRecordsDay;

  /// No description provided for @completed.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get completed;

  /// No description provided for @zonesCompleted.
  ///
  /// In en, this message translates to:
  /// **'{completed} of {total} zones completed'**
  String zonesCompleted(int completed, int total);

  /// No description provided for @mon.
  ///
  /// In en, this message translates to:
  /// **'Mon'**
  String get mon;

  /// No description provided for @tue.
  ///
  /// In en, this message translates to:
  /// **'Tue'**
  String get tue;

  /// No description provided for @wed.
  ///
  /// In en, this message translates to:
  /// **'Wed'**
  String get wed;

  /// No description provided for @thu.
  ///
  /// In en, this message translates to:
  /// **'Thu'**
  String get thu;

  /// No description provided for @fri.
  ///
  /// In en, this message translates to:
  /// **'Fri'**
  String get fri;

  /// No description provided for @sat.
  ///
  /// In en, this message translates to:
  /// **'Sat'**
  String get sat;

  /// No description provided for @sun.
  ///
  /// In en, this message translates to:
  /// **'Sun'**
  String get sun;

  /// No description provided for @jan.
  ///
  /// In en, this message translates to:
  /// **'Jan'**
  String get jan;

  /// No description provided for @feb.
  ///
  /// In en, this message translates to:
  /// **'Feb'**
  String get feb;

  /// No description provided for @mar.
  ///
  /// In en, this message translates to:
  /// **'Mar'**
  String get mar;

  /// No description provided for @apr.
  ///
  /// In en, this message translates to:
  /// **'Apr'**
  String get apr;

  /// No description provided for @jun.
  ///
  /// In en, this message translates to:
  /// **'Jun'**
  String get jun;

  /// No description provided for @jul.
  ///
  /// In en, this message translates to:
  /// **'Jul'**
  String get jul;

  /// No description provided for @aug.
  ///
  /// In en, this message translates to:
  /// **'Aug'**
  String get aug;

  /// No description provided for @sep.
  ///
  /// In en, this message translates to:
  /// **'Sep'**
  String get sep;

  /// No description provided for @oct.
  ///
  /// In en, this message translates to:
  /// **'Oct'**
  String get oct;

  /// No description provided for @nov.
  ///
  /// In en, this message translates to:
  /// **'Nov'**
  String get nov;

  /// No description provided for @dec.
  ///
  /// In en, this message translates to:
  /// **'Dec'**
  String get dec;

  /// No description provided for @weight.
  ///
  /// In en, this message translates to:
  /// **'Weight'**
  String get weight;

  /// No description provided for @waist.
  ///
  /// In en, this message translates to:
  /// **'Waist'**
  String get waist;

  /// No description provided for @chest.
  ///
  /// In en, this message translates to:
  /// **'Chest'**
  String get chest;

  /// No description provided for @hips.
  ///
  /// In en, this message translates to:
  /// **'Hips'**
  String get hips;

  /// No description provided for @armLeft.
  ///
  /// In en, this message translates to:
  /// **'Arm (Left)'**
  String get armLeft;

  /// No description provided for @armRight.
  ///
  /// In en, this message translates to:
  /// **'Arm (Right)'**
  String get armRight;

  /// No description provided for @thighLeft.
  ///
  /// In en, this message translates to:
  /// **'Thigh (Left)'**
  String get thighLeft;

  /// No description provided for @thighRight.
  ///
  /// In en, this message translates to:
  /// **'Thigh (Right)'**
  String get thighRight;

  /// No description provided for @neck.
  ///
  /// In en, this message translates to:
  /// **'Neck'**
  String get neck;

  /// No description provided for @noRecords.
  ///
  /// In en, this message translates to:
  /// **'No records'**
  String get noRecords;

  /// No description provided for @yourProgress.
  ///
  /// In en, this message translates to:
  /// **'Your Progress'**
  String get yourProgress;

  /// No description provided for @completedDays.
  ///
  /// In en, this message translates to:
  /// **'Completed Days'**
  String get completedDays;

  /// No description provided for @beforeAfter.
  ///
  /// In en, this message translates to:
  /// **'Before & After'**
  String get beforeAfter;

  /// No description provided for @viewDifference.
  ///
  /// In en, this message translates to:
  /// **'View difference'**
  String get viewDifference;

  /// No description provided for @before.
  ///
  /// In en, this message translates to:
  /// **'Before'**
  String get before;

  /// No description provided for @timelapse.
  ///
  /// In en, this message translates to:
  /// **'Timelapse'**
  String get timelapse;

  /// No description provided for @exportVideo.
  ///
  /// In en, this message translates to:
  /// **'Export Video'**
  String get exportVideo;

  /// No description provided for @timeline.
  ///
  /// In en, this message translates to:
  /// **'Timeline'**
  String get timeline;

  /// No description provided for @photosCount.
  ///
  /// In en, this message translates to:
  /// **'{count} photos'**
  String photosCount(int count);

  /// No description provided for @noPhotosZone.
  ///
  /// In en, this message translates to:
  /// **'No photos captured for this zone.'**
  String get noPhotosZone;

  /// No description provided for @exportTransformation.
  ///
  /// In en, this message translates to:
  /// **'Export Transformation'**
  String get exportTransformation;

  /// No description provided for @selectVideoQuality.
  ///
  /// In en, this message translates to:
  /// **'Select video quality'**
  String get selectVideoQuality;

  /// No description provided for @lowQuality.
  ///
  /// In en, this message translates to:
  /// **'Low (480p)'**
  String get lowQuality;

  /// No description provided for @mediumQuality.
  ///
  /// In en, this message translates to:
  /// **'Medium (720p)'**
  String get mediumQuality;

  /// No description provided for @highQuality.
  ///
  /// In en, this message translates to:
  /// **'High (1080p)'**
  String get highQuality;

  /// No description provided for @initializing.
  ///
  /// In en, this message translates to:
  /// **'Initializing...'**
  String get initializing;

  /// No description provided for @checkingPermissions.
  ///
  /// In en, this message translates to:
  /// **'Checking permissions...'**
  String get checkingPermissions;

  /// No description provided for @storagePermissionRequired.
  ///
  /// In en, this message translates to:
  /// **'Storage permission required.'**
  String get storagePermissionRequired;

  /// No description provided for @preparingVideoEngine.
  ///
  /// In en, this message translates to:
  /// **'Preparing video engine...'**
  String get preparingVideoEngine;

  /// No description provided for @encodingFrame.
  ///
  /// In en, this message translates to:
  /// **'Encoding frame {current}/{total}'**
  String encodingFrame(int current, int total);

  /// No description provided for @finalizingVideo.
  ///
  /// In en, this message translates to:
  /// **'Finalizing MP4 file...'**
  String get finalizingVideo;

  /// No description provided for @exportComplete.
  ///
  /// In en, this message translates to:
  /// **'Export complete!'**
  String get exportComplete;

  /// No description provided for @exportFailed.
  ///
  /// In en, this message translates to:
  /// **'Export failed: {error}'**
  String exportFailed(String error);

  /// No description provided for @exporting.
  ///
  /// In en, this message translates to:
  /// **'Exporting {quality}'**
  String exporting(String quality);

  /// No description provided for @myTransformation.
  ///
  /// In en, this message translates to:
  /// **'My Transformation'**
  String get myTransformation;

  /// No description provided for @totalDays.
  ///
  /// In en, this message translates to:
  /// **'Total Days'**
  String get totalDays;

  /// No description provided for @body.
  ///
  /// In en, this message translates to:
  /// **'Body'**
  String get body;

  /// No description provided for @after.
  ///
  /// In en, this message translates to:
  /// **'After'**
  String get after;

  /// No description provided for @dismiss.
  ///
  /// In en, this message translates to:
  /// **'Dismiss'**
  String get dismiss;

  /// No description provided for @processing.
  ///
  /// In en, this message translates to:
  /// **'Processing {current}/{total}'**
  String processing(int current, int total);

  /// No description provided for @exportQuality.
  ///
  /// In en, this message translates to:
  /// **'Export Quality'**
  String get exportQuality;

  /// No description provided for @export.
  ///
  /// In en, this message translates to:
  /// **'Export'**
  String get export;

  /// No description provided for @nutrientStatistics.
  ///
  /// In en, this message translates to:
  /// **'Nutrient Statistics'**
  String get nutrientStatistics;

  /// No description provided for @nutritionalIntakeHistory.
  ///
  /// In en, this message translates to:
  /// **'Nutritional intake history'**
  String get nutritionalIntakeHistory;

  /// No description provided for @todaysNutrients.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Nutrients'**
  String get todaysNutrients;

  /// No description provided for @noNutrientsLoggedToday.
  ///
  /// In en, this message translates to:
  /// **'No nutrients logged today'**
  String get noNutrientsLoggedToday;

  /// No description provided for @calories.
  ///
  /// In en, this message translates to:
  /// **'Calories'**
  String get calories;

  /// No description provided for @measurementStatistics.
  ///
  /// In en, this message translates to:
  /// **'Measurement Statistics'**
  String get measurementStatistics;

  /// No description provided for @progressionHistory.
  ///
  /// In en, this message translates to:
  /// **'Progression history'**
  String get progressionHistory;

  /// No description provided for @todaysMeasurements.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Measurements'**
  String get todaysMeasurements;

  /// No description provided for @noMeasurementsLoggedToday.
  ///
  /// In en, this message translates to:
  /// **'No measurements logged today'**
  String get noMeasurementsLoggedToday;

  /// No description provided for @physicalProgress.
  ///
  /// In en, this message translates to:
  /// **'Physical Progress'**
  String get physicalProgress;

  /// No description provided for @trackYourTransformation.
  ///
  /// In en, this message translates to:
  /// **'Track Your Transformation'**
  String get trackYourTransformation;

  /// No description provided for @physicalMeasurementsOverTime.
  ///
  /// In en, this message translates to:
  /// **'Physical measurements over time'**
  String get physicalMeasurementsOverTime;

  /// No description provided for @logEntry.
  ///
  /// In en, this message translates to:
  /// **'Log Entry'**
  String get logEntry;

  /// No description provided for @saveLogs.
  ///
  /// In en, this message translates to:
  /// **'Save Logs'**
  String get saveLogs;

  /// No description provided for @armL.
  ///
  /// In en, this message translates to:
  /// **'Arm (L)'**
  String get armL;

  /// No description provided for @armR.
  ///
  /// In en, this message translates to:
  /// **'Arm (R)'**
  String get armR;

  /// No description provided for @thighL.
  ///
  /// In en, this message translates to:
  /// **'Thigh (L)'**
  String get thighL;

  /// No description provided for @thighR.
  ///
  /// In en, this message translates to:
  /// **'Thigh (R)'**
  String get thighR;

  /// No description provided for @saveAll.
  ///
  /// In en, this message translates to:
  /// **'Save All'**
  String get saveAll;

  /// No description provided for @trackingZones.
  ///
  /// In en, this message translates to:
  /// **'Tracking Zones'**
  String get trackingZones;

  /// No description provided for @additionalTracking.
  ///
  /// In en, this message translates to:
  /// **'Additional Tracking'**
  String get additionalTracking;

  /// No description provided for @appearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearance;

  /// No description provided for @darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get darkMode;

  /// No description provided for @face.
  ///
  /// In en, this message translates to:
  /// **'Face'**
  String get face;

  /// No description provided for @bodyFront.
  ///
  /// In en, this message translates to:
  /// **'Body Front'**
  String get bodyFront;

  /// No description provided for @bodySide.
  ///
  /// In en, this message translates to:
  /// **'Body Side'**
  String get bodySide;

  /// No description provided for @bodyBack.
  ///
  /// In en, this message translates to:
  /// **'Body Back'**
  String get bodyBack;

  /// No description provided for @change.
  ///
  /// In en, this message translates to:
  /// **'Change'**
  String get change;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
