# -*- coding: utf-8 -*-

"""Forward declarations of STK classes
"""

from cython.operator cimport dereference as deref
from libc.stdint cimport uint64_t, int64_t
from libcpp.vector cimport vector
from libcpp.pair cimport pair
from libcpp.map cimport map
from ..topology cimport topology

cdef extern from "stk_mesh/base/Entity.hpp" namespace "stk::mesh" nogil:
    cdef cppclass Entity

cdef extern from "stk_mesh/base/MetaData.hpp" namespace "stk::mesh" nogil:
    cdef cppclass Metadata

cdef extern from "stk_mesh/base/BulkData.hpp" namespace "stk::mesh" nogil:
    cdef cppclass BulkData

cdef extern from "stk_mesh/base/Part.hpp" namespace "stk::mesh" nogil:
    cdef cppclass Part

cdef extern from "stk_mesh/base/FieldBase.hpp" namespace "stk::mesh" nogil:
    cdef cppclass FieldBase

cdef extern from "stk_mesh/base/FieldTraits.hpp" namespace "stk::mesh" nogil:
    cdef cppclass FieldTraits[T]

cdef extern from "stk_mesh/base/Bucket.hpp" namespace "stk::mesh" nogil:
    cdef cppclass Bucket

cdef extern from "stk_mesh/base/Selector.hpp" namespace "stk::mesh" nogil:
    cdef cppclass Selector

cdef extern from "stk_mesh/base/EntityKey.hpp" namespace "stk::mesh" nogil:
    cdef cppclass EntityKey

cdef extern from "stk_mesh/base/Ghosting.hpp" namespace "stk::mesh" nogil:
    cdef cppclass Ghosting

cdef extern from "stk_mesh/base/CoordinateSystems.hpp" namespace "stk::mesh" nogil:
    cdef cppclass Cartesian3d
    cdef cppclass Cartesian2d
    cdef cppclass Cylindrical
    cdef cppclass FullTensor36
    cdef cppclass FullTensor22
    cdef cppclass SymmetricTensor33
    cdef cppclass SymmetricTensor31
    cdef cppclass Matrix33
    cdef cppclass SimpleArrayTag
    ctypedef Cartesian3d Cartesian
    ctypedef SymmetricTensor33 SymmetricTensor
    ctypedef Matrix33 Matrix

cdef extern from "stk_mesh/base/Types.hpp" namespace "stk::mesh" nogil:
    ctypedef vector[Part*] PartVector
    ctypedef vector[Bucket*] BucketVector
    ctypedef vector[const Part*] ConstPartVector
    ctypedef vector[FieldBase*] FieldVector
    ctypedef topology.rank_t EntityRank
    ctypedef unsigned Ordinal
    ctypedef uint64_t EntityId
    ctypedef vector[EntityId] EntityIdVector
    ctypedef pair[Entity, int] EntityProc
    ctypedef vector[EntityProc] EntityProcVec
    ctypedef pair[EntityKey, int] EntityKeyProc
    ctypedef pair[EntityId, int] EntityIdProc
    ctypedef vector[EntityIdProc] EntityIdProcVec
    ctypedef map[EntityId, int] EntityIdProcMap

    cdef cppclass MeshIndex:
        Bucket* bucket
        unsigned bucket_ordinal
        MeshIndex(Bucket* bucketIn, size_t ordinal)

    cdef cppclass FastMeshIndex:
        unsigned bucket_id
        unsigned bucket_ordinal
