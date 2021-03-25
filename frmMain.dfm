object MainForm: TMainForm
  Left = 0
  Top = 0
  Caption = 'GAN - IP Camera Capture Tool'
  ClientHeight = 861
  ClientWidth = 1280
  Color = clBtnFace
  DoubleBuffered = True
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = #45208#45588#44256#46357#53076#46377
  Font.Style = []
  KeyPreview = True
  OldCreateOrder = False
  OnClose = FormClose
  OnCreate = FormCreate
  OnKeyDown = FormKeyDown
  PixelsPerInch = 96
  TextHeight = 11
  object Panel2: TPanel
    Left = 0
    Top = 0
    Width = 1280
    Height = 362
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 0
    object Panel1: TPanel
      Left = 0
      Top = 0
      Width = 1280
      Height = 33
      Align = alTop
      BevelOuter = bvNone
      TabOrder = 0
      DesignSize = (
        1280
        33)
      object Label1: TLabel
        Left = 200
        Top = 9
        Width = 24
        Height = 11
        Caption = '----'
      end
      object Label2: TLabel
        Left = 312
        Top = 9
        Width = 24
        Height = 11
        Caption = '----'
      end
      object Label3: TLabel
        Left = 996
        Top = 5
        Width = 32
        Height = 19
        Anchors = [akTop, akRight]
        Caption = 'Next'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -16
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentFont = False
        ExplicitLeft = 762
      end
      object Current: TLabel
        Left = 890
        Top = 9
        Width = 42
        Height = 11
        Anchors = [akTop, akRight]
        Caption = 'Current'
      end
      object lblCurrentNumber: TLabel
        Left = 933
        Top = 9
        Width = 36
        Height = 11
        Anchors = [akTop, akRight]
        Caption = 'Number'
      end
      object ButtonConnect: TButton
        Left = 6
        Top = 2
        Width = 75
        Height = 25
        Caption = 'Connect'
        TabOrder = 0
        OnClick = ButtonConnectClick
      end
      object ButtonDisconnect: TButton
        Left = 95
        Top = 2
        Width = 75
        Height = 25
        Caption = 'Disconnect'
        TabOrder = 1
        OnClick = ButtonDisconnectClick
      end
      object btnSnapshot: TButton
        Left = 1106
        Top = 2
        Width = 75
        Height = 25
        Anchors = [akTop, akRight]
        Caption = 'Snapshot'
        TabOrder = 2
        OnClick = btnSnapshotClick
      end
      object edtPrefix: TEdit
        Left = 1034
        Top = 2
        Width = 66
        Height = 24
        Anchors = [akTop, akRight]
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -16
        Font.Name = #45208#45588#44256#46357#53076#46377
        Font.Style = []
        MaxLength = 4
        ParentFont = False
        TabOrder = 3
      end
    end
    object RVCamView1: TRVCamView
      Left = 0
      Top = 33
      Width = 784
      Height = 329
      Align = alLeft
      CaptionFont.Charset = DEFAULT_CHARSET
      CaptionFont.Color = clWindowText
      CaptionFont.Height = -11
      CaptionFont.Name = 'Tahoma'
      CaptionFont.Style = []
      DoubleBuffered = True
      TabOrder = 1
      VideoSource = RVCamera1
      UseOptimalVideoResolution = True
      CamMoveMode = vcmmNone
      ViewMode = vvmStretch
    end
    object Panel3: TPanel
      Left = 1088
      Top = 33
      Width = 192
      Height = 329
      Align = alRight
      BevelOuter = bvNone
      ShowCaption = False
      TabOrder = 2
      object mmLog: TMemo
        Left = 0
        Top = 0
        Width = 192
        Height = 329
        Align = alClient
        TabOrder = 0
      end
    end
    object Panel5: TPanel
      Left = 784
      Top = 33
      Width = 304
      Height = 329
      Align = alClient
      BevelOuter = bvNone
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -16
      Font.Name = #45208#45588#44256#46357#53076#46377
      Font.Style = []
      ParentFont = False
      TabOrder = 3
      DesignSize = (
        304
        329)
      object lblMousePoint: TLabel
        Left = 0
        Top = 287
        Width = 304
        Height = 21
        Align = alBottom
        AutoSize = False
        ExplicitTop = 595
        ExplicitWidth = 180
      end
      object lblOrigin: TLabel
        Left = 0
        Top = 308
        Width = 304
        Height = 21
        Align = alBottom
        AutoSize = False
        ExplicitTop = 563
        ExplicitWidth = 180
      end
      object btnBox: TscGPGlyphButton
        Left = 93
        Top = 158
        Width = 87
        Height = 50
        TabOrder = 0
        TabStop = True
        OnClick = btnBoxClick
        Animation = False
        Caption = 'Bag'
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
        ShowCaption = True
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
      object btnMan: TscGPGlyphButton
        Left = 6
        Top = 158
        Width = 87
        Height = 50
        TabOrder = 1
        TabStop = True
        OnClick = btnManClick
        Animation = False
        Caption = 'Man'
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
        GlyphOptions.Kind = scgpbgkRestore
        GlyphOptions.Thickness = 2
        GlyphOptions.StyleColors = True
        TextMargin = -1
        WidthWithCaption = 0
        WidthWithoutCaption = 0
        ShowCaption = True
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
      object btnInit: TButton
        Left = 0
        Top = 0
        Width = 304
        Height = 40
        Align = alTop
        Caption = '&Initialize'
        TabOrder = 2
        OnClick = btnInitClick
      end
      object btnSave: TButton
        Left = 0
        Top = 40
        Width = 304
        Height = 40
        Align = alTop
        Caption = '&Save'
        TabOrder = 3
        OnClick = btnSaveClick
      end
      object btnClose: TButton
        Left = 0
        Top = 80
        Width = 304
        Height = 40
        Align = alTop
        Caption = '&Close'
        TabOrder = 4
        OnClick = btnCloseClick
      end
      object edtMan: TLabeledEdit
        Left = 227
        Top = 158
        Width = 74
        Height = 24
        Alignment = taRightJustify
        Anchors = [akTop, akRight]
        EditLabel.Width = 24
        EditLabel.Height = 16
        EditLabel.Caption = 'Man'
        LabelPosition = lpLeft
        MaxLength = 2
        NumbersOnly = True
        TabOrder = 5
      end
      object edtBag: TLabeledEdit
        Left = 227
        Top = 184
        Width = 74
        Height = 24
        Alignment = taRightJustify
        Anchors = [akTop, akRight]
        EditLabel.Width = 24
        EditLabel.Height = 16
        EditLabel.Caption = 'Bag'
        LabelPosition = lpLeft
        MaxLength = 2
        NumbersOnly = True
        TabOrder = 6
      end
      object edtWorkNo: TLabeledEdit
        Left = 227
        Top = 210
        Width = 74
        Height = 24
        Alignment = taRightJustify
        Anchors = [akTop, akRight]
        EditLabel.Width = 64
        EditLabel.Height = 16
        EditLabel.Caption = 'Work No.'
        LabelPosition = lpLeft
        MaxLength = 3
        NumbersOnly = True
        TabOrder = 7
      end
    end
  end
  object Panel4: TPanel
    Left = 0
    Top = 362
    Width = 1280
    Height = 499
    Align = alClient
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
      ExplicitLeft = 288
      ExplicitTop = 120
      ExplicitWidth = 105
      ExplicitHeight = 105
    end
    object StatusBar1: TStatusBar
      Left = 0
      Top = 480
      Width = 1280
      Height = 19
      Panels = <
        item
          Width = 50
        end>
    end
  end
  object RVCamera1: TRVCamera
    Agent = 'IP Camera'
    URL = 'rtsp://admin:admin@192.168.2.104/stream0'
    CameraPort = 554
    CameraChannel = 0
    CameraSearchTimeOut = 20000
    CommandMode = rvsmNoWait
    DeviceType = rvdtRTSP
    VideoResolution = rv640_480
    FramePerSec = 10
    GStreamerProperty.UseGStreamer = False
    OnGetImage = RVCamera1GetImage
    Left = 384
    Top = 7
  end
end
