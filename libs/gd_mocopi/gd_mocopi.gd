# SPDX-License-Identifier: MIT
# SPDX-FileCopyrightText: 2024 MizunagiKB <mizukb@live.jp>
extends Node
class_name GDMocopi


@export var receive_port: int = 12351
@export var auto_listen: bool = false
@export_node_path("Skeleton3D") var skel_nodepath: NodePath

const MOCOPI_BONE_COUNT: int = 27
const PARAM_UPDATE_NONE: int = 0
const PARAM_UPDATE_REST: int = 1
const PARAM_UPDATE_POSE: int = 2

const DEFAULT_MOCOPI_PARAM: Dictionary = {
    "Hips": {
        "index": 0, "ref": [],
        "x": 0, "y": 0, "z": 0,
        "inv_x": 1, "inv_y": 1, "inv_z": 1,
        "order": "XYZ", "update": PARAM_UPDATE_POSE
    },
    "Spine": {
        "index": 2, "ref": [],
        "x": 0, "y": 0, "z": 0,
        "inv_x": 1, "inv_y": 1, "inv_z": 1,
        "order": "XYZ", "update": PARAM_UPDATE_POSE
    },
    "Chest": {
        "index": 6, "ref": [],
        "x": 0, "y": 0, "z": 0,
        "inv_x": 1, "inv_y": 1, "inv_z": 1,
        "order": "XYZ", "update": PARAM_UPDATE_POSE
    },
    "Neck": {
        "index": 8, "ref": [],
        "x": 0, "y": 0, "z": 0,
        "inv_x": 1, "inv_y": 1, "inv_z": 1,
        "order": "XYZ", "update": PARAM_UPDATE_POSE
    },
    "Head": {
        "index": 10, "ref": [],
        "x": 0, "y": 0, "z": 0,
        "inv_x": 1, "inv_y": 1, "inv_z": 1,
        "order": "XYZ", "update": PARAM_UPDATE_POSE
    },

    "LeftShoulder": {
        "index": 11, "ref": [],
        "x": 0, "y": 0, "z": 0,
        "inv_x": 1, "inv_y": 1, "inv_z": 1,
        "order": "ZXY", "update": PARAM_UPDATE_POSE
    },
    "LeftUpperArm": {
        "index": 12, "ref": [],
        "x": 0, "y": 0, "z": 0,
        "inv_x": 1, "inv_y": -1, "inv_z": -1,
        "order": "ZXY", "update": PARAM_UPDATE_POSE
    },
    "LeftLowerArm": {
        "index": 13, "ref": [],
        "x": 0, "y": 0, "z": 0,
        "inv_x": 1, "inv_y": -1, "inv_z": 1,
        "order": "YXZ", "update": PARAM_UPDATE_POSE
    },
    "LeftHand": {
        "index": 14, "ref": [],
        "x": 0, "y": 0, "z": 0,
        "inv_x": 1, "inv_y": -1, "inv_z": -1,
        "order": "ZXY", "update": PARAM_UPDATE_POSE
    },

    "RightShoulder": {
        "index": 15, "ref": [],
        "x": 0, "y": 0, "z": 0,
        "inv_x": -1, "inv_y": 1, "inv_z": -1,
        "order": "ZXY", "update": PARAM_UPDATE_POSE
    },
    "RightUpperArm": {
        "index": 16, "ref": [],
        "x": 0, "y": 0, "z": 0,
        "inv_x": -1, "inv_y": -1, "inv_z": 1,
        "order": "ZXY", "update": PARAM_UPDATE_POSE
    },
    "RightLowerArm": {
        "index": 17, "ref": [],
        "x": 0, "y": 0, "z": 0,
        "inv_x": -1, "inv_y": 1, "inv_z": 1,
        "order": "YXZ", "update": PARAM_UPDATE_POSE
    },
    "RightHand": {
        "index": 18, "ref": [],
        "x": 0, "y": 0, "z": 0,
        "inv_x": -1, "inv_y": -1, "inv_z": 1,
        "order": "ZXY", "update": PARAM_UPDATE_POSE
    },

    "LeftUpperLeg": {
        "index": 19, "ref": [],
        "x": 0, "y": 0, "z": 0,
        "inv_x": -1, "inv_y": -1, "inv_z": 1,
        "order": "XYZ", "update": PARAM_UPDATE_POSE
    },
    "LeftLowerLeg": {
        "index": 20, "ref": [],
        "x": 0, "y": 0, "z": 0,
        "inv_x": 1, "inv_y": -1, "inv_z": -1,
        "order": "XYZ", "update": PARAM_UPDATE_POSE
    },
    "LeftFoot": {
        "index": 21, "ref": [],
        "x": 0, "y": 0, "z": 0,
        "inv_x": -1, "inv_y": 1, "inv_z": 1,
        "order": "XZY", "update": PARAM_UPDATE_POSE
    },
    "LeftToes": {
        "index": 22, "ref": [],
        "x": 0, "y": 0, "z": 0,
        "inv_x": 1, "inv_y": 1, "inv_z": -1,
        "order": "XZY", "update": PARAM_UPDATE_POSE
    },

    "RightUpperLeg": {
        "index": 23, "ref": [],
        "x": 0, "y": 0, "z": 0,
        "inv_x": -1, "inv_y": -1, "inv_z": 1,
        "order": "XYZ", "update": PARAM_UPDATE_POSE
    },
    "RightLowerLeg": {
        "index": 24, "ref": [],
        "x": 0, "y": 0, "z": 0,
        "inv_x": 1, "inv_y": -1, "inv_z": -1,
        "order": "XYZ", "update": PARAM_UPDATE_POSE
    },
    "RightFoot": {
        "index": 25, "ref": [],
        "x": 0, "y": 0, "z": 0,
        "inv_x": -1, "inv_y": 1, "inv_z": 1,
        "order": "XZY", "update": PARAM_UPDATE_POSE
    },
    "RightToes": {
        "index": 26, "ref": [],
        "x": 0, "y": 0, "z": 0,
        "inv_x": 1, "inv_y": 1, "inv_z": -1,
        "order": "XZY", "update": PARAM_UPDATE_POSE
    }
}

enum E_MOCOPI_BONE {
    root = 0,
    torso_1 = 1, torso_2 = 2, torso_3 = 3, torso_4 = 4, torso_5 = 5, torso_6 = 6, torso_7 = 7,
    neck_1 = 8, neck_2 = 9, head = 10,
    l_shoulder = 11, l_up_arm = 12, l_low_arm = 13, l_hand = 14,
    r_shoulder = 15, r_up_arm = 16, r_low_arm = 17, r_hand = 18,
    l_up_leg = 19, l_low_leg = 20, l_foot = 21, l_toes = 22,
    r_up_leg = 23, r_low_leg = 24, r_foot = 25, r_toes = 26
}

class MocopiBndt:
    var bnid: int
    var pbid: int
    var quat: Quaternion
    var vct3: Vector3

class MocopiBtdt:
    var bnid: int
    var quat: Quaternion
    var vct3: Vector3
    func _init(_bnid: int):
        self.bnid = _bnid

class VRMPose:
    var bnid: int
    var pbid: int
    var bone_name: String
    var quaternion: Quaternion
    var position: Vector3
    
    func _init(_bnid: int, _pbid: int, b: String, q: Quaternion, p: Vector3):
        self.bnid = _bnid
        self.pbid = _pbid
        self.bone_name = b
        self.quaternion = q
        self.position = p


signal vrm_pose_update(time: float, ary_mocopi_animation: Array[VRMPose])


var receiver: UDPServer
var vrsn: int
var fnum: int
var time: float
var uttm: float

var valid_bndt: bool
var ary_bndt: Array[MocopiBndt]
var bndt_count: int

var valid_btdt: bool
var ary_btdt: Array[MocopiBtdt]
var btdt_count: int

# for Skeleton3D
var dict_param: Dictionary


var valid: bool:
    get:
        return self.valid_bndt and self.valid_btdt


func param_load(param_pathname: String) -> bool:
    var rf: FileAccess

    rf = FileAccess.open(param_pathname, FileAccess.READ)
    if rf == null: return false
    dict_param = JSON.parse_string(rf.get_as_text())
    rf.close()

    return true


func param_save(param_pathname: String) -> bool:
    var wf: FileAccess

    wf = FileAccess.open(param_pathname, FileAccess.WRITE)
    if wf == null: return false
    wf.store_string(JSON.stringify(dict_param, "    ", false))
    wf.close()

    return true


func get_skeleton() -> Skeleton3D:
    return self.get_node_or_null(skel_nodepath) as Skeleton3D


func quaternion_calc(src_q: Quaternion, order: String, inv_x: float, inv_y: float, inv_z: float) -> Quaternion:
    var dst_q: Quaternion = Quaternion()

    dst_q.w = src_q.w

    match order:
        "XYZ":
            dst_q.x = src_q.x * inv_x
            dst_q.y = src_q.y * inv_y
            dst_q.z = src_q.z * inv_z

        "XZY":
            dst_q.x = src_q.x * inv_x
            dst_q.y = src_q.z * inv_z
            dst_q.z = src_q.y * inv_y

        "YXZ":
            dst_q.x = src_q.y * inv_y
            dst_q.y = src_q.x * inv_x
            dst_q.z = src_q.z * inv_z

        "YZX":
            dst_q.x = src_q.y * inv_y
            dst_q.y = src_q.z * inv_z
            dst_q.z = src_q.x * inv_x

        "ZXY":
            dst_q.x = src_q.z * inv_z
            dst_q.y = src_q.x * inv_x
            dst_q.z = src_q.y * inv_y

        "ZYX":
            dst_q.x = src_q.z * inv_z
            dst_q.y = src_q.y * inv_y
            dst_q.z = src_q.x * inv_x

        _:
            dst_q.x = src_q.x * inv_x
            dst_q.y = src_q.y * inv_y
            dst_q.z = src_q.z * inv_z

    return dst_q


func skel_update():
    var skel: Skeleton3D = self.get_skeleton()
    if skel == null: return

    if self.valid == false: return

    var ary_mocopi_animation: Array[VRMPose] = []

    for bone_name in dict_param.keys():
        var bone_index: int = skel.find_bone(bone_name)
        if bone_index == -1: continue

        var mocopi_param: Dictionary = dict_param[bone_name]
        var bndt: GDMocopi.MocopiBndt = self.ary_bndt[mocopi_param.index]
        var btdt: GDMocopi.MocopiBtdt = self.ary_btdt[mocopi_param.index]

        var tform_rest: Transform3D = skel.get_bone_rest(bone_index)
        var quat_calc: Quaternion = Quaternion(tform_rest.basis)
        var vct3_calc: Vector3 = btdt.vct3

        if bndt.pbid == -1:
            skel.set_bone_pose_position(bone_index, vct3_calc)

        match int(mocopi_param.update):
            PARAM_UPDATE_NONE:
                pass
            PARAM_UPDATE_REST:
                skel.set_bone_pose_rotation(bone_index, quat_calc)
            PARAM_UPDATE_POSE:
                var qx: Quaternion = Quaternion(Vector3(1.0, 0.0, 0.0), deg_to_rad(mocopi_param.x))
                var qy: Quaternion = Quaternion(Vector3(0.0, 1.0, 0.0), deg_to_rad(mocopi_param.y))
                var qz: Quaternion = Quaternion(Vector3(0.0, 0.0, 1.0), deg_to_rad(mocopi_param.z))
                var quat_remap: Quaternion = quaternion_calc(
                    btdt.quat,
                    mocopi_param.order,
                    mocopi_param.inv_x,
                    mocopi_param.inv_y,
                    mocopi_param.inv_z
                )

                for i in mocopi_param.ref:
                    quat_calc *= ary_btdt[i].quat
                quat_calc = quat_calc * qx * qy * qz * quat_remap
                skel.set_bone_pose_rotation(bone_index, quat_calc)

        ary_mocopi_animation.push_back(
            VRMPose.new(
                bndt.bnid,
                bndt.pbid,
                bone_name,
                quat_calc,
                vct3_calc
            )
        )

    vrm_pose_update.emit(self.time, ary_mocopi_animation)


func listen():
    valid_bndt = false
    valid_btdt = false
    bndt_count = 0
    btdt_count = 0
    self.receiver = UDPServer.new()
    self.receiver.listen(self.receive_port)


func stop():
    receiver.stop()


func _decode_head(stream: StreamPeerBuffer) -> bool:

    var size = stream.get_u32()
    if stream.get_string(4) != "head": return false

    var head_stream: StreamPeerBuffer = StreamPeerBuffer.new()
    var r = stream.get_data(size)
    if r[0] != OK: return false

    head_stream.data_array = PackedByteArray(r[1])

    return true


func _parse_s16(stream: StreamPeerBuffer, text: String) -> int:
    var size: int = stream.get_u32()
    assert(size == 2)
    if stream.get_string(4) != text: return 0
    return stream.get_16()


func _parse_u32(stream: StreamPeerBuffer, text: String) -> int:
    var size: int = stream.get_u32()
    assert(size == 4)
    if stream.get_string(4) != text: return 0
    return stream.get_u32()


func _parse_f32(stream: StreamPeerBuffer, text: String) -> float:
    var size: int = stream.get_u32()
    assert(size == 4)
    if stream.get_string(4) != text: return 0.0
    return stream.get_float()


func _parse_f64(stream: StreamPeerBuffer, text: String) -> float:
    var size: int = stream.get_u32()
    assert(size == 8)
    if stream.get_string(4) != text: return 0.0
    return stream.get_double()


func _decode_sndf(stream: StreamPeerBuffer) -> bool:

    var size = stream.get_u32()
    if stream.get_string(4) != "sndf": return false

    var sndr_stream: StreamPeerBuffer = StreamPeerBuffer.new()
    var r = stream.get_data(size)
    if r[0] != OK: return false

    sndr_stream.data_array = PackedByteArray(r[1])

    size = sndr_stream.get_u32()
    if sndr_stream.get_string(4) != "ipad": return false
    sndr_stream.get_data(size)

    size = sndr_stream.get_u32()
    if sndr_stream.get_string(4) != "rcvp": return false
    sndr_stream.get_data(size)

    return true


func _decode_skdf(stream: StreamPeerBuffer) -> bool:

    var size = stream.get_u32()
    if stream.get_string(4) != "skdf": return false

    var skdf_stream: StreamPeerBuffer = StreamPeerBuffer.new()
    var r = stream.get_data(size)
    if r[0] != OK: return false

    skdf_stream.data_array = PackedByteArray(r[1])

    return _decode_bons(skdf_stream)


func _decode_bons(stream: StreamPeerBuffer) -> bool:

    var size = stream.get_u32()
    if stream.get_string(4) != "bons": return false

    var bons_stream: StreamPeerBuffer = StreamPeerBuffer.new()
    var r = stream.get_data(size)
    if r[0] != OK: return false

    bons_stream.data_array = PackedByteArray(r[1])

    ary_bndt.clear()
    ary_bndt.resize(MOCOPI_BONE_COUNT)

    valid_bndt = false

    for i in range(MOCOPI_BONE_COUNT):

        size = bons_stream.get_u32()
        if bons_stream.get_string(4) != "bndt": return valid_bndt

        var o: MocopiBndt = MocopiBndt.new()

        o.bnid = _parse_s16(bons_stream, "bnid")
        o.pbid = _parse_s16(bons_stream, "pbid")

        size = bons_stream.get_u32()
        if bons_stream.get_string(4) != "tran": return valid_bndt

        o.quat.x = bons_stream.get_float()
        o.quat.y = bons_stream.get_float()
        o.quat.z = bons_stream.get_float()
        o.quat.w = bons_stream.get_float()

        o.vct3.x = bons_stream.get_float()
        o.vct3.y = bons_stream.get_float()
        o.vct3.z = bons_stream.get_float()

        ary_bndt[o.bnid] = o

    valid_bndt = true
    bndt_count += 1

    return valid_bndt


func _decode_fram(stream: StreamPeerBuffer) -> bool:

    var size = stream.get_u32()
    if stream.get_string(4) != "fram": return false

    var fram_stream: StreamPeerBuffer = StreamPeerBuffer.new()
    var r = stream.get_data(size)
    if r[0] != OK: return false

    fram_stream.data_array = PackedByteArray(r[1])

    fnum = _parse_u32(fram_stream, "fnum")
    time = _parse_f32(fram_stream, "time")
    uttm = _parse_f64(fram_stream, "uttm")
    
    return _decode_btrs(fram_stream)


func _decode_btrs(stream: StreamPeerBuffer) -> bool:

    var size = stream.get_u32()
    if stream.get_string(4) != "btrs": return false

    var btrs_stream: StreamPeerBuffer = StreamPeerBuffer.new()
    var r = stream.get_data(size)
    if r[0] != OK: return false

    btrs_stream.data_array = PackedByteArray(r[1])

    ary_btdt.clear()
    ary_btdt.resize(MOCOPI_BONE_COUNT)

    valid_btdt = false

    for i in range(MOCOPI_BONE_COUNT):

        size = btrs_stream.get_u32()
        if btrs_stream.get_string(4) != "btdt": return valid_btdt

        var bnid: int = _parse_s16(btrs_stream, "bnid")
        var o: MocopiBtdt = MocopiBtdt.new(bnid)

        size = btrs_stream.get_u32()
        if btrs_stream.get_string(4) != "tran": return valid_btdt

        o.quat.x = btrs_stream.get_float()
        o.quat.y = btrs_stream.get_float()
        o.quat.z = btrs_stream.get_float()
        o.quat.w = btrs_stream.get_float()

        o.vct3.x = btrs_stream.get_float()
        o.vct3.y = btrs_stream.get_float()
        o.vct3.z = btrs_stream.get_float()

        ary_btdt[o.bnid] = o

    valid_btdt = true
    btdt_count += 1

    return valid_btdt


func _decode(stream: StreamPeerBuffer) -> bool:

    if _decode_head(stream) != true: return false
    if _decode_sndf(stream) != true: return false

    var save_pos: int = stream.get_position()
    var _block_size: int = stream.get_u32()
    var block_name: String = stream.get_string(4)

    stream.seek(save_pos)

    match block_name:
        "skdf":
            if _decode_skdf(stream) != true: return false
        "fram":
            if _decode_fram(stream) != true: return false

    return true
 

func _ready():
    dict_param = DEFAULT_MOCOPI_PARAM

    self.ary_btdt.clear()
    for i in range(MOCOPI_BONE_COUNT):
        self.ary_btdt.append(MocopiBtdt.new(i))

    if self.auto_listen: self.listen()


func _process(_delta):
    if self.receiver == null: return
    if self.receiver.is_listening() == false: return

    self.receiver.poll()

    if self.receiver.is_connection_available() == true:
        var peer: PacketPeerUDP = self.receiver.take_connection()
        var stream: StreamPeerBuffer = StreamPeerBuffer.new()

        stream.data_array = peer.get_packet()

        _decode(stream)

    skel_update()
