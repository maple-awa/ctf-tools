/// 字体配置模型
class FontConfig {
  final String name;
  final String family;
  final double baseSize;
  final String? customPath; // 自定义字体路径
  final bool isSystemFont; // 是否为系统字体

  const FontConfig({
    required this.name,
    required this.family,
    required this.baseSize,
    this.customPath,
    this.isSystemFont = false,
  });

  static const FontConfig defaultFont = FontConfig(
    name: '默认',
    family: 'MapleFont',
    baseSize: 14.0,
  );

  static const List<FontConfig> builtInFonts = [
    FontConfig(name: '默认', family: 'MapleFont', baseSize: 14.0),
    FontConfig(name: '思源黑体', family: 'Noto Sans SC', baseSize: 14.0),
    FontConfig(name: 'Roboto', family: 'Roboto', baseSize: 14.0),
    FontConfig(name: '等宽字体', family: 'monospace', baseSize: 13.0),
    FontConfig(name: '大号字体', family: 'MapleFont', baseSize: 18.0),
  ];

  FontConfig copyWith({
    String? name,
    String? family,
    double? baseSize,
    String? customPath,
    bool? isSystemFont,
  }) {
    return FontConfig(
      name: name ?? this.name,
      family: family ?? this.family,
      baseSize: baseSize ?? this.baseSize,
      customPath: customPath ?? this.customPath,
      isSystemFont: isSystemFont ?? this.isSystemFont,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'family': family,
      'baseSize': baseSize,
      'customPath': customPath,
      'isSystemFont': isSystemFont,
    };
  }

  factory FontConfig.fromJson(Map<String, dynamic> json) {
    return FontConfig(
      name: json['name'] as String? ?? '默认',
      family: json['family'] as String? ?? 'MapleFont',
      baseSize: (json['baseSize'] as num?)?.toDouble() ?? 14.0,
      customPath: json['customPath'] as String?,
      isSystemFont: json['isSystemFont'] as bool? ?? false,
    );
  }
}

/// 布局配置模型
class LayoutConfig {
  final double sidebarWidth;
  final bool compactMode;
  final double cardRadius;
  final double contentPadding;
  final bool showAnimations; // 是否显示动画
  final bool showImages; // 是否显示图片

  const LayoutConfig({
    required this.sidebarWidth,
    required this.compactMode,
    required this.cardRadius,
    required this.contentPadding,
    this.showAnimations = true,
    this.showImages = true,
  });

  static const LayoutConfig defaultLayout = LayoutConfig(
    sidebarWidth: 240.0,
    compactMode: false,
    cardRadius: 12.0,
    contentPadding: 16.0,
    showAnimations: true,
    showImages: true,
  );

  static const LayoutConfig compactLayout = LayoutConfig(
    sidebarWidth: 200.0,
    compactMode: true,
    cardRadius: 8.0,
    contentPadding: 12.0,
    showAnimations: false,
    showImages: true,
  );

  LayoutConfig copyWith({
    double? sidebarWidth,
    bool? compactMode,
    double? cardRadius,
    double? contentPadding,
    bool? showAnimations,
    bool? showImages,
  }) {
    return LayoutConfig(
      sidebarWidth: sidebarWidth ?? this.sidebarWidth,
      compactMode: compactMode ?? this.compactMode,
      cardRadius: cardRadius ?? this.cardRadius,
      contentPadding: contentPadding ?? this.contentPadding,
      showAnimations: showAnimations ?? this.showAnimations,
      showImages: showImages ?? this.showImages,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sidebarWidth': sidebarWidth,
      'compactMode': compactMode,
      'cardRadius': cardRadius,
      'contentPadding': contentPadding,
      'showAnimations': showAnimations,
      'showImages': showImages,
    };
  }

  factory LayoutConfig.fromJson(Map<String, dynamic> json) {
    return LayoutConfig(
      sidebarWidth: (json['sidebarWidth'] as num?)?.toDouble() ?? 240.0,
      compactMode: json['compactMode'] as bool? ?? false,
      cardRadius: (json['cardRadius'] as num?)?.toDouble() ?? 12.0,
      contentPadding: (json['contentPadding'] as num?)?.toDouble() ?? 16.0,
      showAnimations: json['showAnimations'] as bool? ?? true,
      showImages: json['showImages'] as bool? ?? true,
    );
  }
}

/// 编辑器配置模型
class EditorConfig {
  final int fontSize;
  final bool wordWrap;
  final bool lineNumbers;
  final bool minimap;
  final int tabSize;
  final String theme;
  final bool highlightCurrentLine; // 高亮当前行
  final bool highlightMatchingBrackets; // 高亮匹配括号
  final bool renderWhitespace; // 显示空白字符
  final bool bracketPairGuides; // 括号对引导线

  const EditorConfig({
    required this.fontSize,
    required this.wordWrap,
    required this.lineNumbers,
    required this.minimap,
    required this.tabSize,
    required this.theme,
    this.highlightCurrentLine = true,
    this.highlightMatchingBrackets = true,
    this.renderWhitespace = false,
    this.bracketPairGuides = true,
  });

  static const EditorConfig defaultEditor = EditorConfig(
    fontSize: 14,
    wordWrap: true,
    lineNumbers: true,
    minimap: false,
    tabSize: 2,
    theme: 'default',
    highlightCurrentLine: true,
    highlightMatchingBrackets: true,
    renderWhitespace: false,
    bracketPairGuides: true,
  );

  EditorConfig copyWith({
    int? fontSize,
    bool? wordWrap,
    bool? lineNumbers,
    bool? minimap,
    int? tabSize,
    String? theme,
    bool? highlightCurrentLine,
    bool? highlightMatchingBrackets,
    bool? renderWhitespace,
    bool? bracketPairGuides,
  }) {
    return EditorConfig(
      fontSize: fontSize ?? this.fontSize,
      wordWrap: wordWrap ?? this.wordWrap,
      lineNumbers: lineNumbers ?? this.lineNumbers,
      minimap: minimap ?? this.minimap,
      tabSize: tabSize ?? this.tabSize,
      theme: theme ?? this.theme,
      highlightCurrentLine: highlightCurrentLine ?? this.highlightCurrentLine,
      highlightMatchingBrackets:
          highlightMatchingBrackets ?? this.highlightMatchingBrackets,
      renderWhitespace: renderWhitespace ?? this.renderWhitespace,
      bracketPairGuides: bracketPairGuides ?? this.bracketPairGuides,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fontSize': fontSize,
      'wordWrap': wordWrap,
      'lineNumbers': lineNumbers,
      'minimap': minimap,
      'tabSize': tabSize,
      'theme': theme,
      'highlightCurrentLine': highlightCurrentLine,
      'highlightMatchingBrackets': highlightMatchingBrackets,
      'renderWhitespace': renderWhitespace,
      'bracketPairGuides': bracketPairGuides,
    };
  }

  factory EditorConfig.fromJson(Map<String, dynamic> json) {
    return EditorConfig(
      fontSize: json['fontSize'] as int? ?? 14,
      wordWrap: json['wordWrap'] as bool? ?? true,
      lineNumbers: json['lineNumbers'] as bool? ?? true,
      minimap: json['minimap'] as bool? ?? false,
      tabSize: json['tabSize'] as int? ?? 2,
      theme: json['theme'] as String? ?? 'default',
      highlightCurrentLine: json['highlightCurrentLine'] as bool? ?? true,
      highlightMatchingBrackets:
          json['highlightMatchingBrackets'] as bool? ?? true,
      renderWhitespace: json['renderWhitespace'] as bool? ?? false,
      bracketPairGuides: json['bracketPairGuides'] as bool? ?? true,
    );
  }
}

/// 工具偏好配置模型
class ToolPreferences {
  final bool autoCopyResult;
  final bool confirmClear;
  final int maxHistoryItems;
  final bool showTooltips;
  final bool autoSaveHistory; // 自动保存历史
  final String defaultExportFormat; // 默认导出格式
  final bool confirmExit; // 退出前确认
  final bool vibrateOnAction; // 操作时振动反馈

  const ToolPreferences({
    required this.autoCopyResult,
    required this.confirmClear,
    required this.maxHistoryItems,
    required this.showTooltips,
    this.autoSaveHistory = true,
    this.defaultExportFormat = 'txt',
    this.confirmExit = false,
    this.vibrateOnAction = true,
  });

  static const ToolPreferences defaultPrefs = ToolPreferences(
    autoCopyResult: false,
    confirmClear: true,
    maxHistoryItems: 50,
    showTooltips: true,
    autoSaveHistory: true,
    defaultExportFormat: 'txt',
    confirmExit: false,
    vibrateOnAction: true,
  );

  ToolPreferences copyWith({
    bool? autoCopyResult,
    bool? confirmClear,
    int? maxHistoryItems,
    bool? showTooltips,
    bool? autoSaveHistory,
    String? defaultExportFormat,
    bool? confirmExit,
    bool? vibrateOnAction,
  }) {
    return ToolPreferences(
      autoCopyResult: autoCopyResult ?? this.autoCopyResult,
      confirmClear: confirmClear ?? this.confirmClear,
      maxHistoryItems: maxHistoryItems ?? this.maxHistoryItems,
      showTooltips: showTooltips ?? this.showTooltips,
      autoSaveHistory: autoSaveHistory ?? this.autoSaveHistory,
      defaultExportFormat: defaultExportFormat ?? this.defaultExportFormat,
      confirmExit: confirmExit ?? this.confirmExit,
      vibrateOnAction: vibrateOnAction ?? this.vibrateOnAction,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'autoCopyResult': autoCopyResult,
      'confirmClear': confirmClear,
      'maxHistoryItems': maxHistoryItems,
      'showTooltips': showTooltips,
      'autoSaveHistory': autoSaveHistory,
      'defaultExportFormat': defaultExportFormat,
      'confirmExit': confirmExit,
      'vibrateOnAction': vibrateOnAction,
    };
  }

  factory ToolPreferences.fromJson(Map<String, dynamic> json) {
    return ToolPreferences(
      autoCopyResult: json['autoCopyResult'] as bool? ?? false,
      confirmClear: json['confirmClear'] as bool? ?? true,
      maxHistoryItems: json['maxHistoryItems'] as int? ?? 50,
      showTooltips: json['showTooltips'] as bool? ?? true,
      autoSaveHistory: json['autoSaveHistory'] as bool? ?? true,
      defaultExportFormat: json['defaultExportFormat'] as String? ?? 'txt',
      confirmExit: json['confirmExit'] as bool? ?? false,
      vibrateOnAction: json['vibrateOnAction'] as bool? ?? true,
    );
  }
}

/// 界面配置模型
class UIConfig {
  final double scaleFactor; // 界面缩放比例
  final bool useRoundedButtons; // 使用圆角按钮
  final bool showToolDescriptions; // 显示工具描述
  final int itemsPerPage; // 每页显示项目数
  final String dateFormat; // 日期格式
  final String timeFormat; // 时间格式

  const UIConfig({
    required this.scaleFactor,
    required this.useRoundedButtons,
    required this.showToolDescriptions,
    required this.itemsPerPage,
    required this.dateFormat,
    required this.timeFormat,
  });

  static const UIConfig defaultUI = UIConfig(
    scaleFactor: 1.0,
    useRoundedButtons: true,
    showToolDescriptions: true,
    itemsPerPage: 20,
    dateFormat: 'yyyy-MM-dd',
    timeFormat: 'HH:mm:ss',
  );

  UIConfig copyWith({
    double? scaleFactor,
    bool? useRoundedButtons,
    bool? showToolDescriptions,
    int? itemsPerPage,
    String? dateFormat,
    String? timeFormat,
  }) {
    return UIConfig(
      scaleFactor: scaleFactor ?? this.scaleFactor,
      useRoundedButtons: useRoundedButtons ?? this.useRoundedButtons,
      showToolDescriptions: showToolDescriptions ?? this.showToolDescriptions,
      itemsPerPage: itemsPerPage ?? this.itemsPerPage,
      dateFormat: dateFormat ?? this.dateFormat,
      timeFormat: timeFormat ?? this.timeFormat,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'scaleFactor': scaleFactor,
      'useRoundedButtons': useRoundedButtons,
      'showToolDescriptions': showToolDescriptions,
      'itemsPerPage': itemsPerPage,
      'dateFormat': dateFormat,
      'timeFormat': timeFormat,
    };
  }

  factory UIConfig.fromJson(Map<String, dynamic> json) {
    return UIConfig(
      scaleFactor: (json['scaleFactor'] as num?)?.toDouble() ?? 1.0,
      useRoundedButtons: json['useRoundedButtons'] as bool? ?? true,
      showToolDescriptions: json['showToolDescriptions'] as bool? ?? true,
      itemsPerPage: json['itemsPerPage'] as int? ?? 20,
      dateFormat: json['dateFormat'] as String? ?? 'yyyy-MM-dd',
      timeFormat: json['timeFormat'] as String? ?? 'HH:mm:ss',
    );
  }
}

/// 主配置模型
class AppConfig {
  final String language;
  final FontConfig font;
  final LayoutConfig layout;
  final EditorConfig editor;
  final ToolPreferences toolPrefs;
  final UIConfig uiConfig;
  final bool autoSave;
  final String exportPath;
  final DateTime lastModified;
  final String configVersion;

  const AppConfig({
    required this.language,
    required this.font,
    required this.layout,
    required this.editor,
    required this.toolPrefs,
    required this.uiConfig,
    required this.autoSave,
    required this.exportPath,
    required this.lastModified,
    required this.configVersion,
  });

  static final AppConfig defaultConfig = AppConfig(
    language: 'zh_CN',
    font: FontConfig.defaultFont,
    layout: LayoutConfig.defaultLayout,
    editor: EditorConfig.defaultEditor,
    toolPrefs: ToolPreferences.defaultPrefs,
    uiConfig: UIConfig.defaultUI,
    autoSave: true,
    exportPath: '',
    lastModified: DateTime.fromMillisecondsSinceEpoch(0),
    configVersion: '1.0.0',
  );

  AppConfig copyWith({
    String? language,
    FontConfig? font,
    LayoutConfig? layout,
    EditorConfig? editor,
    ToolPreferences? toolPrefs,
    UIConfig? uiConfig,
    bool? autoSave,
    String? exportPath,
    DateTime? lastModified,
    String? configVersion,
  }) {
    return AppConfig(
      language: language ?? this.language,
      font: font ?? this.font,
      layout: layout ?? this.layout,
      editor: editor ?? this.editor,
      toolPrefs: toolPrefs ?? this.toolPrefs,
      uiConfig: uiConfig ?? this.uiConfig,
      autoSave: autoSave ?? this.autoSave,
      exportPath: exportPath ?? this.exportPath,
      lastModified: lastModified ?? this.lastModified,
      configVersion: configVersion ?? this.configVersion,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'language': language,
      'font': font.toJson(),
      'layout': layout.toJson(),
      'editor': editor.toJson(),
      'toolPrefs': toolPrefs.toJson(),
      'uiConfig': uiConfig.toJson(),
      'autoSave': autoSave,
      'exportPath': exportPath,
      'lastModified': lastModified.toIso8601String(),
      'configVersion': configVersion,
    };
  }

  factory AppConfig.fromJson(Map<String, dynamic> json) {
    return AppConfig(
      language: json['language'] as String? ?? 'zh_CN',
      font: FontConfig.fromJson(json['font'] as Map<String, dynamic>? ?? {}),
      layout: LayoutConfig.fromJson(
        json['layout'] as Map<String, dynamic>? ?? {},
      ),
      editor: EditorConfig.fromJson(
        json['editor'] as Map<String, dynamic>? ?? {},
      ),
      toolPrefs: ToolPreferences.fromJson(
        json['toolPrefs'] as Map<String, dynamic>? ?? {},
      ),
      uiConfig: UIConfig.fromJson(
        json['uiConfig'] as Map<String, dynamic>? ?? {},
      ),
      autoSave: json['autoSave'] as bool? ?? true,
      exportPath: json['exportPath'] as String? ?? '',
      lastModified: json['lastModified'] != null
          ? DateTime.parse(json['lastModified'] as String)
          : DateTime.fromMillisecondsSinceEpoch(0),
      configVersion: json['configVersion'] as String? ?? '1.0.0',
    );
  }
}
