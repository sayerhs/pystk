# -*- coding: utf-8 -*-
# distutils: language = c++
# cython: embedsignature = True

from libc.stdint cimport int64_t
from libcpp cimport bool
from libcpp.string cimport string
from libcpp.vector cimport vector
from ..topology.topology cimport topology as topo_cls
from .stk_mesh_fwd cimport *
from .part cimport *
from .bulk cimport *
from .field cimport *

cdef extern from "stk_mesh/base/MetaData.hpp" namespace "stk::mesh" nogil:
    cdef cppclass MetaData:
        MetaData() except +
        MetaData(size_t ndim) except +

        BulkData& mesh_bulk_data()
        const BulkData& mesh_bulk_data() const
        void set_mesh_bulk_data(BulkData* bulk)
        bool has_mesh() const

        Part& universal_part() const
        Part& locally_owned_part() const
        Part& globally_shared_part() const
        Part& aura_part() const

        Part* get_part(const string& part_name,
                       const char* required_by = NULL) const
        Part& get_part(unsigned ordinal) const

        const PartVector& get_parts() const
        const PartVector get_mesh_parts() const
        Part& declare_part(const string& part_name)
        Part& declare_part(const string& part_name, EntityRank rank)
        Part& declare_part_with_topology(
            const string& part_name, topo_cls.topology_t topology)

        void initialize(size_t ndim)
        bool is_initialized() const

        EntityRank side_rank() const
        bool check_rank(EntityRank) const

        field_type* get_field[field_type](EntityRank rank, const string& name) const
        FieldBase* get_field_base "get_field"(EntityRank, const string& name) const
        string coordinate_field_name() const
        void set_coordinate_field_name(const string&) const
        const FieldBase* coordinate_field() const
        void set_coordinate_field(FieldBase* coord_field)
        const FieldVector& get_fields() const
        const FieldVector& get_fields(topo_cls.rank_t rank) const

        field_type& declare_field[field_type](
            topo_cls.rank_t rank, const string& name)
        field_type& declare_field[field_type](
            topo_cls.rank_t rank, const string& name, unsigned number_of_states)

        unsigned spatial_dimension() const
        void commit()
        bool is_commit()

    void set_topology(Part& part, topo_cls topo)

    FieldBase& put_field_on_mesh[FieldBase](
        FieldBase& field, const Part& part, const double* init_value)
    FieldBase& put_field_on_mesh[FieldBase](
        FieldBase& field, const Part& part, unsigned n1, const double* init_value)
    FieldBase& put_field_on_mesh[FieldBase](
        FieldBase& field, const Part& part, unsigned n1, unsigned n2,
        const double* init_value)
    FieldBase& put_field_on_mesh[FieldBase](
        FieldBase& field, const Selector& selector, const double* init_value)
    FieldBase& put_field_on_mesh[FieldBase](
        FieldBase& field, const Selector& selector, unsigned n1, const double* init_value)
    FieldBase& put_field_on_mesh[FieldBase](
        FieldBase& field, const Selector& selector, unsigned n1, unsigned n2,
        const double* init_value)


cdef class StkMetaData:
    cdef MetaData* meta
    cdef bint meta_owner

    @staticmethod
    cdef wrap_instance(MetaData* meta, bint owner=*)
