class_name Rune
extends Resource

@export var strokes: Array[PackedVector2Array] = []

const MIN_DIST := 0.01
const MIN_DIST_SQ := MIN_DIST*MIN_DIST

var rect: Rect2
var points_normalized: PackedVector2Array = []
var points_normalized_vflip: PackedVector2Array = []

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

static func test_error(drawing: Drawing, rune_points_normalized: PackedVector2Array) -> float:
    # var n := resource_path
    var error_sq_total := 0.0
    var count := 0
    for p1 in rune_points_normalized:
        var best_dist_sq := 1e12
        for p2: Vector2 in drawing.points_normalized:
            var dist_sq := p1.distance_squared_to(p2)
            best_dist_sq = min(best_dist_sq, dist_sq)
        var error_sq := max(0.0, best_dist_sq - MIN_DIST_SQ) as float
        error_sq_total += error_sq
        count += 1
    for p1: Vector2 in drawing.points_normalized:
        var best_dist_sq := 1e12
        for p2 in rune_points_normalized:
            var dist_sq := p1.distance_squared_to(p2)
            best_dist_sq = min(best_dist_sq, dist_sq)
        var error_sq := max(0.0, best_dist_sq - MIN_DIST_SQ) as float
        error_sq_total += error_sq
        count += 1
    var variance := sqrt(error_sq_total / count)
    return variance