# -*- coding: utf-8 -*-
# distutils: language = c++
# cython: embedsignature = True

from libcpp cimport bool
from libcpp.string cimport string
from ..util.parallel cimport ParallelMachine
from .stk_mesh_fwd cimport *
from .bucket cimport Bucket

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
        # void sort_entities(const stk::mesh::EntitySorterBase&)
        # void change_entity_owner(const EntityProcVec&)
        void update_field_data_states()
        void update_field_data_states(FieldBase* field)

        const BucketVector& buckets(EntityRank rank) const

        const BucketVector& get_buckets(EntityRank rank, const Selector& selector)

        Entity get_entity(EntityRank rank, EntityId entity_id) const
        Entity get_entity(const EntityKey key) const

        void add_node_sharing(Entity node, int sharing_proc)

        const MeshIndex& mesh_index(Entity entity) const
        EntityId identifier(Entity entity) const
        EntityRank entity_rank(Entity entity) const
        EntityKey entity_key(Entity entity) const
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

        size_t get_size_of_entity_index_space() const

        Part& ghosting_part(const Ghosting& ghosting) const
        Ghosting& aura_ghosting() const
        Ghosting& shared_ghosting() const
        Ghosting& create_ghosting(const string& name)
        void change_ghosting(Ghosting& ghosts, const EntityProcVec& add_send)
        void change_ghosting(
            Ghosting& ghosts, const EntityProcVec& add_send,
            vector[EntityKey]& remove_receive)
        void destroy_ghosting(Ghosting& ghost_layer)
        void destroy_all_ghosting()
        const vector[Ghosting*]& ghostings() const

cdef class StkBulkData:
    cdef BulkData* bulk
    cdef bint bulk_owner

    @staticmethod
    cdef wrap_instance(BulkData* in_bulk, bint owner=*)
