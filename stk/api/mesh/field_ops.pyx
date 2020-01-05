# -*- coding: utf-8 -*-
# distutils: language = c++
# cython: embedsignature = True

"""\
STK field operations
====================

This module exposes the BLAS and parallel operations defined on fields by the
STK library.

For the BLAS operations, the default functions (matching the STK library) are
implemented by default for ``double`` data type. The templated versions for
other data types are implemented with a ``_t`` suffix. For example,
``stk::mesh::field_fill`` is exposed as ``fill`` for ``double``, and a
*templated* version is exposed for other data types as ``fill_t``.

"""

cimport cython
from cython.operator cimport dereference as deref
from libcpp.vector cimport vector
from libcpp.string cimport string
from . cimport field_parallel as fp
from . cimport field_blas as fb

from .meta cimport MetaData
from .bulk cimport StkBulkData
from .field cimport FieldBase, StkFieldBase
from .selector cimport StkSelector
from .ghosting cimport StkGhosting, Ghosting

cdef pyfields_to_cfields(list fields, vector[const FieldBase*]& cfields):
    cdef FieldBase* cfield
    cdef StkFieldBase pyfield
    cdef string fname
    for fld in fields:
        pyfield = fld
        cfield = pyfield.fld
        cfields.push_back(cfield)

def communicate_field_data(StkGhosting ghosting, list fields):
    """Communicate field data for a given ghosting"""
    cdef const Ghosting* sghost = ghosting.ghosting
    cdef vector[const FieldBase*] sfields
    pyfields_to_cfields(fields, sfields)
    fp.communicate_field_data(deref(sghost), sfields)

def copy_owned_to_shared(StkBulkData bulk, list fields):
    """Copy data from owned entities to the shared entities

    Args:
        bulk (StkBulkData): BulkData instance
        fields (list): A list of StkFieldBase instances
    """
    cdef vector[const FieldBase*] sfields
    pyfields_to_cfields(fields, sfields)
    fp.copy_owned_to_shared(deref(bulk.bulk), sfields)

def parallel_sum(StkBulkData bulk, list fields):
    """Parallel sum across all shared entities for a given list of fields

    Args:
        bulk (StkBulkData): BulkData instance
        fields (list): A list of StkFieldBase instances
    """
    cdef vector[const FieldBase*] sfields
    pyfields_to_cfields(fields, sfields)
    fp.parallel_sum(deref(bulk.bulk), sfields)

def parallel_max(StkBulkData bulk, list fields):
    """Parallel max

    Args:
        bulk (StkBulkData): BulkData instance
        fields (list): A list of StkFieldBase instances
    """
    cdef vector[const FieldBase*] sfields
    pyfields_to_cfields(fields, sfields)
    fp.parallel_max(deref(bulk.bulk), sfields)

def parallel_min(StkBulkData bulk, list fields):
    """Parallel min

    Args:
        bulk (StkBulkData): BulkData instance
        fields (list): A list of StkFieldBase instances
    """
    cdef vector[const FieldBase*] sfields
    pyfields_to_cfields(fields, sfields)
    fp.parallel_min(deref(bulk.bulk), sfields)

def parallel_sum_including_ghosts(StkBulkData bulk, list fields):
    """Parallel sum"""
    cdef vector[const FieldBase*] sfields
    pyfields_to_cfields(fields, sfields)
    fp.parallel_sum_including_ghosts(deref(bulk.bulk), sfields)

def parallel_max_including_ghosts(StkBulkData bulk, list fields):
    """Parallel max"""
    cdef vector[const FieldBase*] sfields
    pyfields_to_cfields(fields, sfields)
    fp.parallel_max_including_ghosts(deref(bulk.bulk), sfields)

def parallel_min_including_ghosts(StkBulkData bulk, list fields):
    """Parallel min"""
    cdef vector[const FieldBase*] sfields
    pyfields_to_cfields(fields, sfields)
    fp.parallel_min_including_ghosts(deref(bulk.bulk), sfields)


def axpy(double alpha, StkFieldBase xfield, StkFieldBase yfield, StkSelector sel = None):
    """y = alpha * x + y

    Args:
        alpha (double): Constant coefficient
        xfield (StkFieldBase): Source field
        yfield (StkFieldBase): Destination field
        sel (StkSelector): A selector to restrict where the BLAS operation is carried out
    """
    if sel is None:
        fb.field_axpy(alpha, deref(xfield.fld), deref(yfield.fld))
    else:
        fb.field_axpy(alpha, deref(xfield.fld), deref(yfield.fld), sel.sel)

def fill(double alpha, StkFieldBase field, StkSelector sel = None):
    """field[:] = alpha

    Args:

        alpha (double): Constant coefficient
        field (StkFieldBase): Field to be updated
        sel (StkSelector): A selector to restrict where the BLAS operation is carried out
    """
    if sel is None:
        fb.field_fill(alpha, deref(field.fld))
    else:
        fb.field_fill(alpha, deref(field.fld), sel.sel)

def fill_component(double[:] alpha, StkFieldBase field, StkSelector sel = None):
    """field[:] = alpha[:]

    Args:
        alpha (double):  Component values
        field (StkFieldBase): Field to be updated
        sel (StkSelector): A selector to restrict where the BLAS operation is carried out
    """
    if sel is None:
        fb.field_fill_component(&alpha[0], deref(field.fld))
    else:
        fb.field_fill_component(&alpha[0], deref(field.fld), sel.sel)

def axpy_t(cython.numeric alpha, StkFieldBase xfield, StkFieldBase yfield, StkSelector sel = None):
    """y = alpha * x + y"""
    if sel is None:
        fb.field_axpy(alpha, deref(xfield.fld), deref(yfield.fld))
    else:
        fb.field_axpy(alpha, deref(xfield.fld), deref(yfield.fld), sel.sel)

def fill_t(cython.numeric alpha, StkFieldBase field, StkSelector sel = None):
    """field[:] = alpha"""
    if sel is None:
        fb.field_fill(alpha, deref(field.fld))
    else:
        fb.field_fill(alpha, deref(field.fld), sel.sel)

def fill_component_t(cython.numeric[:] alpha, StkFieldBase field, StkSelector sel = None):
    """field[:] = alpha"""
    if sel is None:
        fb.field_fill_component(&alpha[0], deref(field.fld))
    else:
        fb.field_fill_component(&alpha[0], deref(field.fld), sel.sel)

def copy(StkFieldBase xfield, StkFieldBase yfield, StkSelector sel=None):
    """yfield = xfield

    Args:
        xfield (StkFieldBase): Source field
        yfield (StkFieldBase): Destination field
        sel (StkSelector): Restrict copy to only entities belonging to selector
    """
    if sel is None:
        fb.field_copy(deref(xfield.fld), deref(yfield.fld))
    else:
        fb.field_copy(deref(xfield.fld), deref(yfield.fld), sel.sel)

def swap(StkFieldBase xfield, StkFieldBase yfield, StkSelector sel=None):
    """Swap the contents of x and y fields

    Args:
        xfield (StkFieldBase): Field for swapping
        yfield (StkFieldBase): Field for swapping
        sel (StkSelector): Restrict swap to only entities belonging to selector
    """
    if sel is None:
        fb.field_swap(deref(xfield.fld), deref(yfield.fld))
    else:
        fb.field_swap(deref(xfield.fld), deref(yfield.fld), sel.sel)
