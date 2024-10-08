--!strict
--!native
--!optimize 2

return {
	USE_DEFAULT_CONSTRAINT_INFO = false,
	DISABLE_HEAD_COLLISION_ON_RAGDOLL = true,
	CREATE_NO_COLLISION_CONSTRAINTS_AUTO = true,
	CREATE_NO_COLLISION_CONSTRAINTS_ROOT = true,
	USE_AUTO_CREATED_CONSTRAINTS_IF_JOINT_NOT_PROVIDED_IN_INFO = true,
	USE_AUTO_CREATED_CONSTRAINTS_IF_JOINT_PROVIDED_IN_INFO = true,

	RAGDOLL_ON_FALL_COOLDOWN = 0.6,

	RAGDOLL_CAMERA_SPRING = true,
	RAGDOLL_CAMERA_SPRING_DAMPER = 0.8,
	RAGDOLL_CAMERA_SPRING_SPEED = 20,

	RENDER_PLAYER_CHARACTERS_ON_CLIENT_AFTER_DIED = false,

	DEFAULT_CONSTRAINT_INFO = {},
}
