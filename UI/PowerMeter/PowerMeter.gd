extends MarginContainer


# ------------------------------------------------------------------------------
# Onready Variables
# ------------------------------------------------------------------------------
@onready var progress : TextureProgressBar = $TPB

# ------------------------------------------------------------------------------
# Public Methods
# ------------------------------------------------------------------------------
func increment_bar(tainted : bool) -> void:
	var amount : float = 0.5 if tainted else 1.0
	progress.value = max(0.0, min(progress.max_value, progress.value + amount))

func reset() -> void:
	progress.value = 0
