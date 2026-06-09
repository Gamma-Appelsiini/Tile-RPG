extends RigidBody3D
class_name CraftingGemOrb

@export var gem_mesh: MeshInstance3D = null
@export var gem_pickup_sound:AudioStream = null
@export var gem_drop_sound:AudioStream = null
@export var particles: CPUParticles3D = null
@export var collision_shape_3d: CollisionShape3D = null
@export var curve_mover: CurveMover = null

const EXPLOSION_SPEED:float = 6

func _ready() -> void:
	top_level = true
	freeze = true

func shoot_gem() -> void:
	freeze = false
	var vel:Vector3 = (self.global_transform.origin - GlobalSignals.player.global_transform.origin) * EXPLOSION_SPEED
	self.linear_velocity = vel
	GlobalSignals.play_audio.emit(gem_drop_sound, AudioManager.AUDIO_TYPE.SOUND_EFFECT, self.global_position)
	
	await get_tree().create_timer(2.5).timeout

	curve_mover.target_reached.connect(_on_pickup)
	curve_mover.move_to_target(self, GlobalSignals.player)

func _on_pickup()-> void:
	GlobalSignals.play_audio.emit(gem_pickup_sound, AudioManager.AUDIO_TYPE.SOUND_EFFECT, self.global_position)
	GlobalSignals.ui_handler.inventory.player_gems += 1
	_delete_gem()

func _delete_gem()-> void:
	self.freeze = true
	freeze_mode = FREEZE_MODE_STATIC
	
	var tween:Tween = create_tween().set_ease(Tween.EASE_IN)
	tween.tween_property(gem_mesh,"scale",Vector3(0.01,0.01,0.01), .1)
	await tween.finished
	
	particles.emitting = true
	await get_tree().create_timer(0.5).timeout
	queue_free()
