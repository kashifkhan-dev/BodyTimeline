// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get today => 'Hoy';

  @override
  String get profile => 'Perfil';

  @override
  String get deleteData => 'Eliminar Datos';

  @override
  String get language => 'Idioma';

  @override
  String get settings => 'Ajustes';

  @override
  String get history => 'Historial';

  @override
  String get progress => 'Progreso';

  @override
  String get english => 'Inglés';

  @override
  String get spanish => 'Español';

  @override
  String get save => 'Guardar';

  @override
  String get cancel => 'Cancelar';

  @override
  String get updateProfilePicture => 'Actualizar Foto de Perfil';

  @override
  String get back => 'Atrás';

  @override
  String get todaysTasks => 'Tareas de Hoy';

  @override
  String get logDay => 'Registrar Día';

  @override
  String get logged => 'Registrado';

  @override
  String get pending => 'Pendiente';

  @override
  String get macros => 'Macros';

  @override
  String get measurements => 'Medidas';

  @override
  String get recorded => 'Grabado';

  @override
  String get notRecorded => 'No registrado';

  @override
  String get done => 'Completado';

  @override
  String get greatJob => '¡Buen trabajo!';

  @override
  String get almostThere => '¡Casi listo!';

  @override
  String get dailyGoalReached => 'Has alcanzado tu objetivo diario.';

  @override
  String get completeOneMoreTask =>
      'Completa 1 tarea más para alcanzar tu objetivo.';

  @override
  String get dailyGoal => 'OBJETIVO DIARIO';

  @override
  String tasksRemaining(int count, int total) {
    return '$count de $total tareas restantes';
  }

  @override
  String get facePhoto => 'Foto de Cara';

  @override
  String get bodyFrontPhoto => 'Foto Frontal';

  @override
  String get bodySidePhoto => 'Foto Lateral';

  @override
  String get bodyBackPhoto => 'Foto de Espalda';

  @override
  String get bodyMeasurements => 'Medidas Corporales';

  @override
  String get macronutrients => 'Macronutrientes';

  @override
  String capturedAt(String time) {
    return 'Captured at $time';
  }

  @override
  String get pendingRegistration => 'Registro pendiente';

  @override
  String get monday => 'Lunes';

  @override
  String get tuesday => 'Martes';

  @override
  String get wednesday => 'Miércoles';

  @override
  String get thursday => 'Jueves';

  @override
  String get friday => 'Viernes';

  @override
  String get saturday => 'Sábado';

  @override
  String get sunday => 'Domingo';

  @override
  String get january => 'Enero';

  @override
  String get february => 'Febrero';

  @override
  String get march => 'Marzo';

  @override
  String get april => 'Abril';

  @override
  String get may => 'May';

  @override
  String get june => 'Junio';

  @override
  String get july => 'Julio';

  @override
  String get august => 'Agosto';

  @override
  String get september => 'Septiembre';

  @override
  String get october => 'Octubre';

  @override
  String get november => 'Noviembre';

  @override
  String get december => 'Diciembre';

  @override
  String get changeAvatar => 'CAMBIAR AVATAR';

  @override
  String get latestProgressImage => 'Última Imagen de Progreso';

  @override
  String get useRecentFrontPhoto => 'Usa tu foto frontal más reciente';

  @override
  String get chooseFromGallery => 'Elegir de la Galería';

  @override
  String get pickImageFromDevice => 'Elige una imagen de tu dispositivo';

  @override
  String get preview => 'Vista Previa';

  @override
  String get deleteDataTitle => 'Eliminar Todos los Datos';

  @override
  String get deleteDataWarning =>
      'Esta acción es irreversible. Todo tu historial de entrenamiento, fotos y progreso se eliminarán permanentemente.';

  @override
  String get confirmDelete => 'Eliminar Todo';

  @override
  String get cancelDeletion => 'No, conservar mis datos';

  @override
  String get dataDeleted => 'Datos borrados con éxito';

  @override
  String get avatarSelection => 'Selección de Avatar';

  @override
  String get saveProfileChanges => 'Guardar Cambios de Perfil';

  @override
  String get syncsWithLatestBodyPhoto =>
      'Se sincroniza con tu última foto corporal';

  @override
  String get uploadCustomPicture => 'Sube una foto personalizada';

  @override
  String get profileSettings => 'Ajustes de Perfil';

  @override
  String get nuclearOption => 'Crítico: Opción Nuclear';

  @override
  String get deleteDataLongWarning =>
      'Esta acción es irreversible. Todas las fotos, registros, progreso y ajustes se eliminarán permanentemente de este dispositivo.';

  @override
  String get deleteConfirmation => 'eliminar todo';

  @override
  String typeToDelete(String word) {
    return 'Escribe \"$word\" para confirmar:';
  }

  @override
  String get dangerZone => 'Zona de Peligro';

  @override
  String get resetApplication => 'Reiniciar Aplicación';

  @override
  String get allDataCleared => 'Todos los datos han sido borrados.';

  @override
  String get streak => 'Racha';

  @override
  String get activitySuffix => 'Actividad';

  @override
  String get nutrientsOverview => 'Vista General de Nutrientes';

  @override
  String get measurementsOverview => 'Vista General de Medidas';

  @override
  String get currentStreak => 'RACHA ACTUAL';

  @override
  String get days => 'días';

  @override
  String daysActive(int count) {
    return '$count días activo';
  }

  @override
  String daysMissed(int count) {
    return '$count días perdidos';
  }

  @override
  String get avgCalories => 'PROM. CAL.';

  @override
  String get protein => 'PROTEÍNAS';

  @override
  String get carbs => 'CARBOS';

  @override
  String get fats => 'GRASAS';

  @override
  String get dailyAverage => 'Promedio diario';

  @override
  String get latestRecorded => 'Último registrado';

  @override
  String get noMeasurementsYet => 'No hay medidas registradas';

  @override
  String get noRecordsDay => 'No hay registros para este día';

  @override
  String get completed => 'Completado';

  @override
  String zonesCompleted(int completed, int total) {
    return '$completed de $total zonas completadas';
  }

  @override
  String get mon => 'Lun';

  @override
  String get tue => 'Mar';

  @override
  String get wed => 'Mié';

  @override
  String get thu => 'Jue';

  @override
  String get fri => 'Vie';

  @override
  String get sat => 'Sáb';

  @override
  String get sun => 'Dom';

  @override
  String get jan => 'Ene';

  @override
  String get feb => 'Feb';

  @override
  String get mar => 'Mar';

  @override
  String get apr => 'Abr';

  @override
  String get jun => 'Jun';

  @override
  String get jul => 'Jul';

  @override
  String get aug => 'Ago';

  @override
  String get sep => 'Sep';

  @override
  String get oct => 'Oct';

  @override
  String get nov => 'Nov';

  @override
  String get dec => 'Dic';

  @override
  String get weight => 'Peso';

  @override
  String get waist => 'Cintura';

  @override
  String get chest => 'Pecho';

  @override
  String get hips => 'Cadera';

  @override
  String get armLeft => 'Brazo (Izq)';

  @override
  String get armRight => 'Brazo (Der)';

  @override
  String get thighLeft => 'Muslo (Izq)';

  @override
  String get thighRight => 'Muslo (Der)';

  @override
  String get neck => 'Cuello';

  @override
  String get noRecords => 'No hay registros';

  @override
  String get yourProgress => 'Tu Progreso';

  @override
  String get completedDays => 'Días Completados';

  @override
  String get beforeAfter => 'Antes y Después';

  @override
  String get viewDifference => 'Ver diferencia';

  @override
  String get before => 'Antes';

  @override
  String get timelapse => 'Timelapse';

  @override
  String get exportVideo => 'Exportar Video';

  @override
  String get timeline => 'Cronología';

  @override
  String photosCount(int count) {
    return '$count fotos';
  }

  @override
  String get noPhotosZone => 'No hay fotos capturadas para esta zona.';

  @override
  String get exportTransformation => 'Exportar Transformación';

  @override
  String get selectVideoQuality => 'Seleccionar calidad de video';

  @override
  String get lowQuality => 'Baja (480p)';

  @override
  String get mediumQuality => 'Media (720p)';

  @override
  String get highQuality => 'Alta (1080p)';

  @override
  String get initializing => 'Inicializando...';

  @override
  String get checkingPermissions => 'Comprobando permisos...';

  @override
  String get storagePermissionRequired =>
      'Se requiere permiso de almacenamiento.';

  @override
  String get preparingVideoEngine => 'Preparando motor de video...';

  @override
  String encodingFrame(int current, int total) {
    return 'Codificando fotograma $current/$total';
  }

  @override
  String get finalizingVideo => 'Finalizando archivo MP4...';

  @override
  String get exportComplete => '¡Exportación completa!';

  @override
  String exportFailed(String error) {
    return 'Error en la exportación: $error';
  }

  @override
  String exporting(String quality) {
    return 'Exportando $quality';
  }

  @override
  String get myTransformation => 'Mi Transformación';

  @override
  String get totalDays => 'Días Totales';

  @override
  String get body => 'Cuerpo';

  @override
  String get after => 'Después';

  @override
  String get dismiss => 'Cerrar';

  @override
  String processing(int current, int total) {
    return 'Procesando $current/$total';
  }

  @override
  String get exportQuality => 'Calidad de Exportación';

  @override
  String get export => 'Exportar';

  @override
  String get nutrientStatistics => 'Estadísticas de Nutrientes';

  @override
  String get nutritionalIntakeHistory => 'Historial de ingesta nutricional';

  @override
  String get todaysNutrients => 'Nutrientes de Hoy';

  @override
  String get noNutrientsLoggedToday => 'No hay nutrientes registrados hoy';

  @override
  String get calories => 'Calorías';

  @override
  String get measurementStatistics => 'Estadísticas de Medidas';

  @override
  String get progressionHistory => 'Historial de progresión';

  @override
  String get todaysMeasurements => 'Medidas de Hoy';

  @override
  String get noMeasurementsLoggedToday => 'No hay medidas registradas hoy';

  @override
  String get physicalProgress => 'Progreso Físico';

  @override
  String get trackYourTransformation => 'Sigue tu Transformación';

  @override
  String get physicalMeasurementsOverTime =>
      'Medidas físicas a lo largo del tiempo';

  @override
  String get logEntry => 'Registrar Entrada';

  @override
  String get saveLogs => 'Guardar Registros';

  @override
  String get armL => 'Brazo (I)';

  @override
  String get armR => 'Brazo (D)';

  @override
  String get thighL => 'Muslo (I)';

  @override
  String get thighR => 'Muslo (D)';

  @override
  String get saveAll => 'Guardar Todo';

  @override
  String get trackingZones => 'Zonas de Rastreo';

  @override
  String get additionalTracking => 'Rastreo Adicional';

  @override
  String get automation => 'Automatización';

  @override
  String get useLatestPhotoAsAvatar => 'Usar última foto como avatar';

  @override
  String get appearance => 'Apariencia';

  @override
  String get darkMode => 'Modo Oscuro';

  @override
  String get face => 'Cara';

  @override
  String get bodyFront => 'Frente';

  @override
  String get bodySide => 'Lado';

  @override
  String get bodyBack => 'Espalda';

  @override
  String get change => 'Cambiar';
}
