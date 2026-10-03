class_name AlderwakeDockSurfaces
extends RefCounted
## M006 authored migration exception, approved by user. Not refreshed source data.
## Registered at source dock feet; shallow decks share flat Y=0 until M008.

const SURFACES: Dictionary = {
	"dock-row-dock-straight-west-building": [Rect2(-20.5, 17, 5, 2), Rect2(-19, 14.5, 2, 2.5)],
	"dock-row-dock-junction-building": [Rect2(-15.5, 17, 5, 2), Rect2(-14, 19, 2, 1), Rect2(-14, 14, 2, 3)],
	"dock-row-dock-straight-east-building": [Rect2(-10.5, 17, 5, 2), Rect2(-7.5, 14.5, 2, 2.5)],
}


static func cutouts() -> Array[Rect2]:
	var result: Array[Rect2] = []
	for surfaces: Array in SURFACES.values():
		for rect: Rect2 in surfaces:
			result.append(rect)
	return result


static func subtract(rect: Rect2, cuts: Array[Rect2]) -> Array[Rect2]:
	var pieces: Array[Rect2] = [rect]
	for mask: Rect2 in cuts:
		var remaining: Array[Rect2] = []
		for piece: Rect2 in pieces:
			var cut: Rect2 = piece.intersection(mask)
			if not cut.has_area():
				remaining.append(piece)
				continue
			for part: Rect2 in [Rect2(piece.position, Vector2(piece.size.x, cut.position.y - piece.position.y)),
				Rect2(piece.position.x, cut.end.y, piece.size.x, piece.end.y - cut.end.y),
				Rect2(piece.position.x, cut.position.y, cut.position.x - piece.position.x, cut.size.y),
				Rect2(cut.end.x, cut.position.y, piece.end.x - cut.end.x, cut.size.y)]:
				if part.has_area():
					remaining.append(part)
		pieces = remaining
	return pieces
