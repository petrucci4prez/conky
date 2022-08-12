let Vector2 = \(a : Type) -> { x : a, y : a }

let Point = Vector2 Natural

let Margin = Vector2 Natural

let FSPath = { name : Text, path : Text }

let FileSystem = { show_smart : Bool, fs_paths : List FSPath }

let Graphics =
      { dev_power : Text
      , show_temp : Bool
      , show_clock : Bool
      , show_gpu_util : Bool
      , show_mem_util : Bool
      , show_vid_util : Bool
      }

let Memory =
      { show_stats : Bool
      , show_plot : Bool
      , show_swap : Bool
      , table_rows : Natural
      }

let Processor =
      { core_rows : Natural
      , core_padding : Natural
      , show_stats : Bool
      , show_plot : Bool
      , table_rows : Natural
      }

let RaplSpec = { name : Text, address : Text }

let Power = { battery : Text, rapl_specs : List RaplSpec }

let ReadWrite = { devices : List Text }

let ModType =
      < filesystem : FileSystem
      | graphics : Graphics
      | memory : Memory
      | network
      | pacman
      | processor : Processor
      | power : Power
      | readwrite : ReadWrite
      | system
      >

let Annotated = \(a : Type) -> { type : Text, data : a }

let Block = < Pad : Natural | Mod : Annotated ModType >

let Column_ = { blocks : List Block, width : Natural }

let Column = < CPad : Natural | CCol : Column_ >

let Panel_ = { columns : List Column, margins : Margin }

let Panel = < PPad : Natural | PPanel : Panel_ >

let Layout = { anchor : Point, panels : List Panel }

let Sizes =
      { Type =
          { normal : Natural
          , plot_label : Natural
          , table : Natural
          , header : Natural
          }
      , default = { normal = 13, plot_label = 8, table = 11, header = 15 }
      }

let Font =
      { Type = { family : Text, sizes : Sizes.Type }
      , default = { family = "Neuropolitical", sizes = Sizes::{=} }
      }

let PlotGeometry =
      { Type =
          { spacing : Natural
          , height : Natural
          , seconds : Natural
          , ticks : Vector2 Natural
          }
      , default =
        { seconds = 90, ticks = { x = 9, y = 4 }, height = 56, spacing = 20 }
      }

let TableGeometry =
      { Type =
          { name_chars : Natural
          , padding : Margin
          , header_padding : Natural
          , row_spacing : Natural
          }
      , default =
        { name_chars = 8
        , padding = { x = 6, y = 15 }
        , header_padding = 20
        , row_spacing = 16
        }
      }

let HeaderGeometry =
      { Type = { underline_offset : Natural, padding : Natural }
      , default = { underline_offset = 26, padding = 19 }
      }

let Geometry =
      { Type =
          { plot : PlotGeometry.Type
          , table : TableGeometry.Type
          , header : HeaderGeometry.Type
          }
      , default =
        { plot = PlotGeometry::{=}
        , table = TableGeometry::{=}
        , header = HeaderGeometry::{=}
        }
      }

let StopRGB = { color : Natural, stop : Double }

let StopRGBA = { color : Natural, stop : Double, alpha : Double }

let ColorAlpha = { color : Natural, alpha : Double }

let Pattern =
      < RGB : Natural
      | RGBA : ColorAlpha
      | GradientRGB : List StopRGB
      | GradientRGBA : List StopRGBA
      >

let annotatePattern =
      \(a : Pattern) ->
        { type = showConstructor a, data = a } : Annotated Pattern

let mod = \(a : ModType) -> Block.Mod { type = showConstructor a, data = a }

let APattern = Annotated Pattern

let symGradient =
      \(c0 : Natural) ->
      \(c1 : Natural) ->
        annotatePattern
          ( Pattern.GradientRGB
              [ { color = c0, stop = 0.0 }
              , { color = c1, stop = 0.5 }
              , { color = c0, stop = 1.0 }
              ]
          )

let Patterns =
      { Type =
          { header : APattern
          , panel : { bg : APattern }
          , text :
              { active : APattern, inactive : APattern, critical : APattern }
          , border : APattern
          , plot :
              { grid : APattern
              , outline : APattern
              , data : { border : APattern, fill : APattern }
              }
          , indicator :
              { bg : APattern, fg : { active : APattern, critical : APattern } }
          }
      , default =
        { header = annotatePattern (Pattern.RGB 0xefefef)
        , panel.bg
          = annotatePattern (Pattern.RGBA { color = 0x121212, alpha = 0.7 })
        , text =
          { active = annotatePattern (Pattern.RGB 0xbfe1ff)
          , inactive = annotatePattern (Pattern.RGB 0xc8c8c8)
          , critical = annotatePattern (Pattern.RGB 0xff8282)
          }
        , border = annotatePattern (Pattern.RGB 0x888888)
        , plot =
          { grid = annotatePattern (Pattern.RGB 0x666666)
          , outline = annotatePattern (Pattern.RGB 0x777777)
          , data =
            { border =
                annotatePattern
                  ( Pattern.GradientRGB
                      [ { color = 0x003f7c, stop = 0.0 }
                      , { color = 0x1e90ff, stop = 1.0 }
                      ]
                  )
            , fill =
                annotatePattern
                  ( Pattern.GradientRGBA
                      [ { color = 0x316ece, stop = 0.2, alpha = 0.5 }
                      , { color = 0x8cc7ff, stop = 1.0, alpha = 1.0 }
                      ]
                  )
            }
          }
        , indicator =
          { bg = symGradient 0x565656 0xbfbfbf
          , fg =
            { active = symGradient 0x316BA6 0x99CEFF
            , critical = symGradient 0xFF3333 0xFFB8B8
            }
          }
        }
      }

let Theme =
      { Type =
          { font : Font.Type
          , geometry : Geometry.Type
          , patterns : Patterns.Type
          }
      , default =
        { font = Font::{=}, geometry = Geometry::{=}, patterns = Patterns::{=} }
      }

let Bootstrap = { update_interval : Natural, dimensions : Point }

let Config = { bootstrap : Bootstrap, theme : Theme.Type, layout : Layout }

let toConfig =
      \(i : Natural) ->
      \(x : Natural) ->
      \(y : Natural) ->
      \(t : Theme.Type) ->
      \(l : Layout) ->
          { bootstrap = { update_interval = i, dimensions = { x, y } }
          , theme = t
          , layout = l
          }
        : Config

in  { toConfig
    , Block
    , Column
    , ModType
    , Layout
    , Panel
    , FSPath
    , FileSystem
    , Graphics
    , Memory
    , Processor
    , Power
    , ReadWrite
    , Theme
    , mod
    }
