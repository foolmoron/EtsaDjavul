class_name Rune
extends Resource

@export_range(0.0, 0.1, 0.01) var max_error = 0.09
@export var text = ""
@export var text_plural = ""
@export var text_genitive = ""
@export var text_genitive_plural = ""
@export var text_accusative = ""
@export var text_accusative_plural = ""
@export var neg_prefix = ""
@export var strokes: Array[PackedVector2Array] = []

const MIN_DIST := 0.01
const MIN_DIST_SQ := MIN_DIST*MIN_DIST

var rect: Rect2
var points_normalized: PackedVector2Array = []
var points_normalized_vflip: PackedVector2Array = []
var points_normalized_rot: PackedVector2Array = []
var points_normalized_rot_vflip: PackedVector2Array = []

var did_ready := false
func on_ready():
    if did_ready:
        return
    did_ready = true
    rect = Rect2(strokes[0][0], Vector2(0, 0))
    for s in strokes:
        for p in s:
            rect = rect.expand(p)
    for s in strokes:
        for p in s:
            var p2 = (p - rect.position) / rect.size
            points_normalized.append(p2)
            points_normalized_vflip.append(Vector2(p2.x, 1.0 - p2.y))
            var p2_rot = Vector2(0.5 - (p2.y - 0.5), 0.5 + (p2.x - 0.5))
            points_normalized_rot.append(p2_rot)
            points_normalized_rot_vflip.append(Vector2(p2_rot.x, 1.0 - p2_rot.y))

static func test_error(drawing: Drawing, rune_points_normalized: PackedVector2Array, best: float) -> float:
    # var n := resource_path
    var error_sq_total := 0.0
    var count := rune_points_normalized.size() + drawing.points_normalized.size()
    for p1 in rune_points_normalized:
        var best_dist_sq := 1e12
        for p2: Vector2 in drawing.points_normalized:
            var dist_sq := p1.distance_squared_to(p2)
            best_dist_sq = min(best_dist_sq, dist_sq)
        var error_sq := max(0.0, best_dist_sq - MIN_DIST_SQ) as float
        error_sq_total += error_sq / count
        if error_sq_total > best:
            return 9999.0
    for p1: Vector2 in drawing.points_normalized:
        var best_dist_sq := 1e12
        for p2 in rune_points_normalized:
            var dist_sq := p1.distance_squared_to(p2)
            best_dist_sq = min(best_dist_sq, dist_sq)
        var error_sq := max(0.0, best_dist_sq - MIN_DIST_SQ) as float
        error_sq_total += error_sq / count
        if error_sq_total > best:
            return 9999.0
    return error_sq_total