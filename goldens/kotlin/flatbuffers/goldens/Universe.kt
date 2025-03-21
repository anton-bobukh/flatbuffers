// automatically generated by the FlatBuffers compiler, do not modify

package flatbuffers.goldens

import com.google.flatbuffers.BaseVector
import com.google.flatbuffers.BooleanVector
import com.google.flatbuffers.ByteVector
import com.google.flatbuffers.Constants
import com.google.flatbuffers.DoubleVector
import com.google.flatbuffers.FlatBufferBuilder
import com.google.flatbuffers.FloatVector
import com.google.flatbuffers.LongVector
import com.google.flatbuffers.StringVector
import com.google.flatbuffers.Struct
import com.google.flatbuffers.Table
import com.google.flatbuffers.UnionVector
import java.nio.ByteBuffer
import java.nio.ByteOrder
import kotlin.math.sign

@Suppress("unused")
class Universe : Table() {

    fun __init(_i: Int, _bb: ByteBuffer)  {
        __reset(_i, _bb)
    }
    fun __assign(_i: Int, _bb: ByteBuffer) : Universe {
        __init(_i, _bb)
        return this
    }
    val age : Double
        get() {
            val o = __offset(4)
            return if(o != 0) bb.getDouble(o + bb_pos) else 0.0
        }
    fun galaxies(j: Int) : flatbuffers.goldens.Galaxy? = galaxies(flatbuffers.goldens.Galaxy(), j)
    fun galaxies(obj: flatbuffers.goldens.Galaxy, j: Int) : flatbuffers.goldens.Galaxy? {
        val o = __offset(6)
        return if (o != 0) {
            obj.__assign(__indirect(__vector(o) + j * 4), bb)
        } else {
            null
        }
    }
    val galaxiesLength : Int
        get() {
            val o = __offset(6); return if (o != 0) __vector_len(o) else 0
        }
    companion object {
        fun validateVersion() = Constants.FLATBUFFERS_25_2_10()
        fun getRootAsUniverse(_bb: ByteBuffer): Universe = getRootAsUniverse(_bb, Universe())
        fun getRootAsUniverse(_bb: ByteBuffer, obj: Universe): Universe {
            _bb.order(ByteOrder.LITTLE_ENDIAN)
            return (obj.__assign(_bb.getInt(_bb.position()) + _bb.position(), _bb))
        }
        fun createUniverse(builder: FlatBufferBuilder, age: Double, galaxiesOffset: Int) : Int {
            builder.startTable(2)
            addAge(builder, age)
            addGalaxies(builder, galaxiesOffset)
            return endUniverse(builder)
        }
        fun startUniverse(builder: FlatBufferBuilder) = builder.startTable(2)
        fun addAge(builder: FlatBufferBuilder, age: Double) = builder.addDouble(0, age, 0.0)
        fun addGalaxies(builder: FlatBufferBuilder, galaxies: Int) = builder.addOffset(1, galaxies, 0)
        fun createGalaxiesVector(builder: FlatBufferBuilder, data: IntArray) : Int {
            builder.startVector(4, data.size, 4)
            for (i in data.size - 1 downTo 0) {
                builder.addOffset(data[i])
            }
            return builder.endVector()
        }
        fun startGalaxiesVector(builder: FlatBufferBuilder, numElems: Int) = builder.startVector(4, numElems, 4)
        fun endUniverse(builder: FlatBufferBuilder) : Int {
            val o = builder.endTable()
            return o
        }
        fun finishUniverseBuffer(builder: FlatBufferBuilder, offset: Int) = builder.finish(offset)
        fun finishSizePrefixedUniverseBuffer(builder: FlatBufferBuilder, offset: Int) = builder.finishSizePrefixed(offset)
    }
}
