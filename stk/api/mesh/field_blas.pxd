# -*- coding: utf-8 -*-
# distutils: language = c++
# cython: embedsignature = True

from libcpp.vector cimport vector
from .bulk cimport BulkData
from .field cimport FieldBase
from .selector cimport Selector

cdef extern from "stk_mesh/base/FieldBLAS.hpp" namespace "stk::mesh":
    void field_axpy[Scalar](const Scalar alpha, const FieldBase& xField,
                            const FieldBase& yField, const Selector& sel)

    void field_axpy[Scalar](const Scalar alpha, const FieldBase& xField,
                            const FieldBase& yField)

    void field_copy(const FieldBase& xField, const FieldBase& yField,
                    const Selector& sel)
    void field_copy(const FieldBase& xField, const FieldBase& yField)

    void field_swap(const FieldBase& xField, const FieldBase& yField,
                    const Selector& sel)
    void field_swap(const FieldBase& xField, const FieldBase& yField)

    void field_fill[Scalar](const Scalar alpha, const FieldBase& field)
    void field_fill[Scalar](const Scalar alpha, const FieldBase& field, const Selector& sel)
    void field_fill_component[Scalar](
        const Scalar* alpha, const FieldBase& field)
    void field_fill_component[Scalar](
        const Scalar* alpha, const FieldBase& field, const Selector& sel)
