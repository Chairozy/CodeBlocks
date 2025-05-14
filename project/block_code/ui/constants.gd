extends Object

const CURRENT_DATA_VERSION = 0

const KNOB_X = 15.0
const KNOB_W = 12.0
const KNOB_H = 4.0
const KNOB_Z = 4.0
const CONTROL_MARGIN = 20.0
const OUTLINE_WIDTH = 3.0
const COLOR_DARKNED = 0.5
const MINIMUM_SNAP_DISTANCE = 80.0
const MINIMUM_DRAG_THRESHOLD = 25

const FOCUS_BORDER_COLOR = Color(225, 255, 255)
const EXEC_BORDER_COLOR = Color(225, 242, 0)


## Properties for builtin categories. Order starts at 10 for the first
## category and then are separated by 10 to allow custom categories to
## be easily placed between builtin categories.
const BUILTIN_CATEGORIES_PROPS: Dictionary = {
	"Lifecycle":
	{
		"color": Color("dddd44"),
		"order": 10,
	},
	"Motions":
	{
		"color": Color("dddddd"),
		"order": 10,
	},
	"Lifecycle | Spawn":
	{
		"color": Color("dddddd"),
		"order": 15,
	},
	"Transform | Position":
	{
		"color": Color("dddddd"),
		"order": 20,
	},
	"Transform | Rotation":
	{
		"color": Color("dddddd"),
		"order": 30,
	},
	"Transform | Scale":
	{
		"color": Color("dddddd"),
		"order": 40,
	},
	"Graphics | Modulate":
	{
		"color": Color("dddddd"),
		"order": 50,
	},
	"Graphics | Visibility":
	{
		"color": Color("dddddd"),
		"order": 60,
	},
	"Graphics | Viewport":
	{
		"color": Color("dddddd"),
		"order": 61,
	},
	"Graphics | Animation":
	{
		"color": Color("dddddd"),
		"order": 62,
	},
	"Sounds":
	{
		"color": Color("dddddd"),
		"order": 70,
	},
	"Physics | Mass":
	{
		"color": Color("dddddd"),
		"order": 80,
	},
	"Physics | Velocity":
	{
		"color": Color("dddddd"),
		"order": 90,
	},
	"Input":
	{
		"color": Color("dddddd"),
		"order": 100,
	},
	"Communication | Methods":
	{
		"color": Color("dddddd"),
		"order": 110,
	},
	"Communication | Nodes":
	{
		"color": Color("dddddd"),
		"order": 115,
	},
	"Communication | Groups":
	{
		"color": Color("dddddd"),
		"order": 120,
	},
	"Info | Score":
	{
		"color": Color("dddddd"),
		"order": 130,
	},
	"Loops":
	{
		"color": Color("dddddd"),
		"order": 140,
	},
	"Logic | Conditionals":
	{
		"color": Color("dddddd"),
		"order": 150,
	},
	"Logic | Comparison":
	{
		"color": Color("dddddd"),
		"order": 160,
	},
	"Logic | Boolean":
	{
		"color": Color("dddddd"),
		"order": 170,
	},
	"Variables":
	{
		"color": Color("dddddd"),
		"order": 180,
	},
	"Math":
	{
		"color": Color("dddddd"),
		"order": 190,
	},
	"Log":
	{
		"color": Color("dddddd"),
		"order": 200,
	},
}
