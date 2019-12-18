# -*- coding: utf-8 -*-
# distutils: language = c++
# cython: embedsignature = True

from libcpp cimport bool
from libcpp.string cimport string
from libcpp.vector cimport vector
from ..util.parallel cimport ParallelMachine
from ..mesh.bulk cimport BulkData
from ..mesh.field cimport FieldBase

cdef extern from "Ioss_Property.h" namespace "Ioss":
    cdef cppclass Property:
        Property(string name, const string& value)
        Property(string name, int value)
        Property(string name, double value)

cdef extern from "stk_io/DatabasePurpose.hpp" namespace "stk::io":
    cpdef enum DatabasePurpose:
        PURPOSE_UNKNOWN
        WRITE_RESULTS
        WRITE_RESTART
        READ_MESH
        READ_RESTART
        APPEND_RESULTS

cdef extern from "stk_io/MeshField.hpp" namespace "stk::io::MeshField":
    cpdef enum TimeMatchOption:
        LINEAR_INTERPOLATION
        CLOSEST
        SPECIFIED

cdef extern from "stk_io/MeshField.hpp" namespace "stk::io":
    cdef cppclass MeshField:
        MeshField& set_read_time(double time_to_read)
        MeshField& set_active()
        MeshField& set_inactive()
        MeshField& set_single_state(bool yesno)
        MeshField& set_read_once(bool yesno)
        MeshField& set_classic_restart()
        FieldBase* field() const
        bool is_active


cdef extern from "stk_io/InputFile.hpp" namespace "stk::io::InputFile":
    cpdef enum PeriodType:
        CYCLIC,
        REVERSING

cdef extern from "stk_io/InputFile.hpp" namespace "stk::io":
    cdef cppclass InputFile:
        InputFile& set_offset_time(double offset_time)
        InputFile& set_scale_time(double scale_time)
        InputFile& set_start_time(double start_time)
        InputFile& set_stop_time(double stop_time)
        InputFile& set_periodic_time(double period_len, double startup_time, PeriodType ptype)
        InputFile& set_periodic_time(double period_len, double startup_time)
        InputFile& set_periodic_time(double period_len)


cdef extern from "stk_io/StkMeshIoBroker.hpp" namespace "stk::io":
    cdef cppclass StkMeshIoBroker:
        StkMeshIoBroker()
        StkMeshIoBroker(ParallelMachine comm)

        void set_bulk_data(BulkData&)
        void property_add(const Property& prop)

        size_t add_mesh_database(const string& filename,
                                 DatabasePurpose purpose) except +
        size_t add_mesh_database(const string& filename,
                                 const string& type,
                                 DatabasePurpose purpose) except +


        InputFile& get_mesh_database(size_t input_file_index)
        void remove_mesh_database(size_t input_file_index) except +
        size_t set_active_mesh(size_t input_file_index)
        size_t get_active_mesh() const

        void create_input_mesh()
        void populate_bulk_data()
        void populate_mesh()
        void populate_field_data()
        void add_all_mesh_fields_as_input_fields()
        void add_all_mesh_fields_as_input_fields(TimeMatchOption tmo)
        double read_defined_input_fields(int step);
        double read_defined_input_fields(int step,
                                       vector[MeshField]* missing)
        double read_defined_input_fields_at_step(int step,
                                         vector[MeshField]* missing)
        double read_defined_input_fields(double time);
        double read_defined_input_fields(double time,
                                       vector[MeshField]* missing)

        size_t create_output_mesh(const string& filename, DatabasePurpose purpose)
        size_t create_output_mesh(const string& filename, DatabasePurpose purpose, double time)
        void write_output_mesh(size_t file_index)
        void add_field(size_t file_index, FieldBase& field)
        void add_field(size_t file_index, FieldBase& field, const string& field_db_name)
        void begin_output_step(size_t file_index, double time)
        void end_output_step(size_t file_index)

        int get_num_time_steps()
        double get_max_time()
        vector[double] get_time_steps()
        void set_max_num_steps_before_overwrite(
            size_t file_index, int max_num_steps_in_file)

        int write_defined_output_fields(size_t file_index)
        void flush_output() const
        int process_output_request(size_t file_index, double time)

        void write_global(size_t file_index, const string& name, double data)
        void write_global(size_t file_index, const string& name, int data)


cdef class StkIoBroker:
    cdef StkMeshIoBroker* stkio
    cdef bint stkio_owner

    @staticmethod
    cdef wrap_instance(StkMeshIoBroker* stkio, bint owner=*)
