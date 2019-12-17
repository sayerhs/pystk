# -*- coding: utf-8 -*-
# distutils: language = c++
# cython: embedsignature = True

from ..util.parallel cimport ParallelMachine
from .stk_mesh_fwd cimport *
from .bucket cimport *
from .part cimport *
from .meta cimport *

cdef extern from "stk_mesh/base/BulkData.hpp" namespace "stk::mesh" nogil:
    cdef cppclass BulkData:
        BulkData(MetaData& meta, ParallelMachine parallel) except +

        MetaData& mesh_meta_data()

        ParallelMachine parallel() const
        int parallel_size() const
        int parallel_rank() const

        bool in_modifiable_state() const
        bool in_synchronized_state() const
        bool is_automatic_aura_on() const
        size_t synchronized_count() const

        bool modification_begin()
        bool modification_end()
        void update_field_data_states()

        const BucketVector& buckets(EntityRank rank) const

        const BucketVector& get_buckets(EntityRank rank, const Selector& selector)

        EntityId identifier(Entity entity) const
        Bucket& bucket(Entity entity) const
        size_t bucket_ordinal(Entity entity) const
        int parallel_owner_rank(Entity entity) const
        unsigned local_id(Entity entity) const
        uint64_t get_max_allowed_id() const

        const Entity* begin(Entity entity, EntityRank rank) const
        const Entity* begin_nodes(Entity entity) const
        const Entity* begin_edges(Entity entity) const
        const Entity* begin_faces(Entity entity) const
        const Entity* begin_elements(Entity entity) const

        unsigned num_nodes(Entity entity) const
        unsigned num_edges(Entity entity) const
        unsigned num_faces(Entity entity) const
        unsigned num_elements(Entity entity) const
        unsigned num_sides(Entity entity) const

cdef class StkBulkData:
    cdef BulkData* bulk
    cdef bint bulk_owner

    @staticmethod
    cdef wrap_instance(BulkData* in_bulk, bint owner=*)
