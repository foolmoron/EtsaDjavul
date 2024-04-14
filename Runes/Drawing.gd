class_name Drawing

const DEDUPE_GRID_DIST := 10.0
const DEDUPE_SNAP_VEC := Vector2(DEDUPE_GRID_DIST, DEDUPE_GRID_DIST)

var points: Array = []
var points_normalized: PackedVector2Array = []
var rect: Rect2

func _init(lines: Array[PackedVector2Array]):
    var drawing_points_hash: Dictionary = {}
    for l in lines:
        for p in l:
            var rounded_to_grid: Vector2 = p#snapped(p, DEDUPE_SNAP_VEC)
            drawing_points_hash[rounded_to_grid] = null
    points = drawing_points_hash.keys()
    rect = Rect2(points[0], Vector2(0, 0))
    for p in points:
        rect = rect.expand(p)
    for p in points:
        points_normalized.append((p - rect.position) / rect.size)
    pass

func get_sort_value() -> float:
    return -rect.get_center().dot(Vector2(0.5, 1)) # top-leftmost wins, with higher weight to horizontal
