object EditImage: TEditImage
  Left = 0
  Top = 0
  Caption = 'EditImage'
  ClientHeight = 484
  ClientWidth = 1484
  Color = clBtnFace
  Constraints.MinHeight = 480
  Constraints.MinWidth = 640
  Font.Charset = ANSI_CHARSET
  Font.Color = clWindowText
  Font.Height = -16
  Font.Name = #47569#51008' '#44256#46357
  Font.Style = []
  OldCreateOrder = False
  Position = poDesigned
  OnClose = FormClose
  OnCreate = FormCreate
  OnKeyDown = FormKeyDown
  PixelsPerInch = 96
  TextHeight = 21
  object pnlEditImage: TPanel
    Left = 1284
    Top = 0
    Width = 200
    Height = 484
    Align = alRight
    BevelOuter = bvNone
    Caption = 'pnlEditImage'
    ShowCaption = False
    TabOrder = 0
    DesignSize = (
      200
      484)
    object lblMousePoint: TLabel
      Left = 0
      Top = 463
      Width = 200
      Height = 21
      Align = alBottom
      AutoSize = False
      ExplicitTop = 595
      ExplicitWidth = 180
    end
    object lblOrigin: TLabel
      Left = 0
      Top = 442
      Width = 200
      Height = 21
      Align = alBottom
      AutoSize = False
      ExplicitTop = 563
      ExplicitWidth = 180
    end
    object lblBeginPoint: TLabel
      Left = 17
      Top = 266
      Width = 48
      Height = 21
      Anchors = [akLeft, akBottom]
      Caption = #49884#51089#51216
      ExplicitTop = 315
    end
    object lblEndPoint: TLabel
      Left = 17
      Top = 338
      Width = 32
      Height = 21
      Anchors = [akLeft, akBottom]
      Caption = #45149#51216
      ExplicitTop = 387
    end
    object btnInit: TButton
      Left = 0
      Top = 0
      Width = 200
      Height = 40
      Align = alTop
      Caption = '&Initialize'
      TabOrder = 0
      OnClick = btnInitClick
    end
    object btnSaveAndClose: TButton
      Left = 0
      Top = 40
      Width = 200
      Height = 40
      Align = alTop
      Caption = '&SaveAndClose'
      TabOrder = 1
      OnClick = btnSaveAndCloseClick
    end
    object btnClose: TButton
      Left = 0
      Top = 80
      Width = 200
      Height = 40
      Align = alTop
      Caption = '&Close'
      TabOrder = 2
      OnClick = btnCloseClick
    end
    object btnCrop: TscGPGlyphButton
      Left = 4
      Top = 126
      Width = 96
      Height = 50
      Enabled = False
      TabOrder = 3
      TabStop = True
      OnClick = btnCropClick
      Animation = False
      Caption = 'btnCrop'
      CanFocused = True
      CustomDropDown = False
      Layout = blGlyphLeft
      TransparentBackground = True
      ColorValue = clRed
      Options.NormalColor = clBtnText
      Options.HotColor = clBtnText
      Options.PressedColor = clBtnText
      Options.FocusedColor = clBtnFace
      Options.DisabledColor = clBtnText
      Options.NormalColorAlpha = 10
      Options.HotColorAlpha = 20
      Options.PressedColorAlpha = 30
      Options.FocusedColorAlpha = 255
      Options.DisabledColorAlpha = 5
      Options.FrameNormalColor = clBtnText
      Options.FrameHotColor = clBtnText
      Options.FramePressedColor = clBtnText
      Options.FrameFocusedColor = clHighlight
      Options.FrameDisabledColor = clBtnText
      Options.FrameWidth = 2
      Options.FrameNormalColorAlpha = 70
      Options.FrameHotColorAlpha = 100
      Options.FramePressedColorAlpha = 150
      Options.FrameFocusedColorAlpha = 255
      Options.FrameDisabledColorAlpha = 30
      Options.FontNormalColor = clBtnText
      Options.FontHotColor = clBtnText
      Options.FontPressedColor = clBtnText
      Options.FontFocusedColor = clBtnText
      Options.FontDisabledColor = clBtnShadow
      Options.ShapeFillGradientAngle = 90
      Options.ShapeFillGradientPressedAngle = -90
      Options.ShapeCornerRadius = 10
      Options.ShapeStyle = scgpSegmentedLeftRounded
      Options.ArrowSize = 9
      Options.StyleColors = True
      GlyphOptions.NormalColor = clBtnText
      GlyphOptions.HotColor = clBtnText
      GlyphOptions.PressedColor = clBtnText
      GlyphOptions.FocusedColor = clBtnText
      GlyphOptions.DisabledColor = clBtnText
      GlyphOptions.NormalColorAlpha = 200
      GlyphOptions.HotColorAlpha = 255
      GlyphOptions.PressedColorAlpha = 255
      GlyphOptions.FocusedColorAlpha = 255
      GlyphOptions.DisabledColorAlpha = 100
      GlyphOptions.Kind = scgpbgkCut
      GlyphOptions.Thickness = 2
      GlyphOptions.StyleColors = True
      TextMargin = -1
      WidthWithCaption = 0
      WidthWithoutCaption = 0
      RepeatClick = False
      RepeatClickInterval = 100
      ShowGalleryMenuFromTop = False
      ShowGalleryMenuFromRight = False
      ShowMenuArrow = True
      ShowFocusRect = True
      Down = False
      GroupIndex = 0
      AllowAllUp = False
    end
    object btnBox: TscGPGlyphButton
      Left = 100
      Top = 126
      Width = 96
      Height = 50
      TabOrder = 4
      TabStop = True
      OnClick = btnBoxClick
      Animation = False
      Caption = 'scGPGlyphButton1'
      CanFocused = True
      CustomDropDown = False
      Layout = blGlyphLeft
      TransparentBackground = True
      ColorValue = clRed
      Options.NormalColor = clBtnText
      Options.HotColor = clBtnText
      Options.PressedColor = clBtnText
      Options.FocusedColor = clBtnFace
      Options.DisabledColor = clBtnText
      Options.NormalColorAlpha = 10
      Options.HotColorAlpha = 20
      Options.PressedColorAlpha = 30
      Options.FocusedColorAlpha = 255
      Options.DisabledColorAlpha = 5
      Options.FrameNormalColor = clBtnText
      Options.FrameHotColor = clBtnText
      Options.FramePressedColor = clBtnText
      Options.FrameFocusedColor = clHighlight
      Options.FrameDisabledColor = clBtnText
      Options.FrameWidth = 2
      Options.FrameNormalColorAlpha = 70
      Options.FrameHotColorAlpha = 100
      Options.FramePressedColorAlpha = 150
      Options.FrameFocusedColorAlpha = 255
      Options.FrameDisabledColorAlpha = 30
      Options.FontNormalColor = clBtnText
      Options.FontHotColor = clBtnText
      Options.FontPressedColor = clBtnText
      Options.FontFocusedColor = clBtnText
      Options.FontDisabledColor = clBtnShadow
      Options.ShapeFillGradientAngle = 90
      Options.ShapeFillGradientPressedAngle = -90
      Options.ShapeCornerRadius = 10
      Options.ShapeStyle = scgpSegmentedRightRounded
      Options.ArrowSize = 9
      Options.StyleColors = True
      GlyphOptions.NormalColor = clBtnText
      GlyphOptions.HotColor = clBtnText
      GlyphOptions.PressedColor = clBtnText
      GlyphOptions.FocusedColor = clBtnText
      GlyphOptions.DisabledColor = clBtnText
      GlyphOptions.NormalColorAlpha = 200
      GlyphOptions.HotColorAlpha = 255
      GlyphOptions.PressedColorAlpha = 255
      GlyphOptions.FocusedColorAlpha = 255
      GlyphOptions.DisabledColorAlpha = 100
      GlyphOptions.Kind = scgpbgkRestore
      GlyphOptions.Thickness = 2
      GlyphOptions.StyleColors = True
      TextMargin = -1
      WidthWithCaption = 0
      WidthWithoutCaption = 0
      RepeatClick = False
      RepeatClickInterval = 100
      ShowGalleryMenuFromTop = False
      ShowGalleryMenuFromRight = False
      ShowMenuArrow = True
      ShowFocusRect = True
      Down = False
      GroupIndex = 0
      AllowAllUp = False
    end
    object edtBeginX: TLabeledEdit
      Left = 104
      Top = 263
      Width = 89
      Height = 29
      Anchors = [akLeft, akBottom]
      EditLabel.Width = 10
      EditLabel.Height = 21
      EditLabel.Caption = 'X'
      LabelPosition = lpLeft
      NumbersOnly = True
      TabOrder = 5
    end
    object edtBeginY: TLabeledEdit
      Left = 104
      Top = 298
      Width = 89
      Height = 29
      Anchors = [akLeft, akBottom]
      EditLabel.Width = 9
      EditLabel.Height = 21
      EditLabel.Caption = 'Y'
      LabelPosition = lpLeft
      NumbersOnly = True
      TabOrder = 6
    end
    object edtEndX: TLabeledEdit
      Left = 103
      Top = 335
      Width = 89
      Height = 29
      Anchors = [akLeft, akBottom]
      EditLabel.Width = 10
      EditLabel.Height = 21
      EditLabel.Caption = 'X'
      LabelPosition = lpLeft
      NumbersOnly = True
      TabOrder = 7
    end
    object edtEndY: TLabeledEdit
      Left = 103
      Top = 370
      Width = 89
      Height = 29
      Anchors = [akLeft, akBottom]
      EditLabel.Width = 9
      EditLabel.Height = 21
      EditLabel.Caption = 'Y'
      LabelPosition = lpLeft
      NumbersOnly = True
      TabOrder = 8
    end
    object btnManualCrop: TButton
      Left = 0
      Top = 407
      Width = 200
      Height = 35
      Align = alBottom
      Caption = 'Manual Crop'
      TabOrder = 9
      OnClick = btnManualCropClick
    end
  end
  object ScrollBox1: TScrollBox
    Left = 0
    Top = 0
    Width = 1284
    Height = 484
    HorzScrollBar.Range = 129
    HorzScrollBar.Smooth = True
    VertScrollBar.Range = 129
    Align = alClient
    AutoScroll = False
    BevelInner = bvNone
    BevelOuter = bvNone
    TabOrder = 1
    object imgEdit: TsImage
      Left = 0
      Top = 0
      Width = 1280
      Height = 480
      Align = alClient
      Picture.Data = {07544269746D617000000000}
      OnMouseDown = imgEditMouseDown
      OnMouseMove = imgEditMouseMove
      OnMouseUp = imgEditMouseUp
      SkinData.SkinSection = 'CHECKBOX'
      ExplicitTop = -3
    end
  end
end
