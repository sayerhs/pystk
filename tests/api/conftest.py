# -*- coding: utf-8 -*-

import pytest
import numpy as np
from stk.stk.stk_mesh import StkMesh

@pytest.fixture
def hex_1elem_mesh(parallel):
    """Simple 1 element mesh with only metadata initialized"""
    mesh = StkMesh(parallel)
    mesh.read_mesh_meta_data("generated:1x1x1|sideset:xXyYzZ")
    return mesh

@pytest.fixture
def stk_mesh(hex_1elem_mesh):
    """Simple 1 element mesh with no fields"""
    hex_1elem_mesh.populate_bulk_data(create_edges=True)
    return hex_1elem_mesh

@pytest.fixture
def stk_mesh_fields(hex_1elem_mesh):
    """Simple 1 element mesh with test fields"""
    mesh = hex_1elem_mesh
    pressure = mesh.meta.declare_scalar_field("pressure")
    velocity = mesh.meta.declare_vector_field("velocity", number_of_states=2)
    pressure.add_to_part(
        mesh.meta.universal_part,
        init_value=np.array([20.0]))
    velocity.add_to_part(
        mesh.meta.universal_part,
        mesh.meta.spatial_dimension,
        init_value=np.array([10.0, 5.0, 0.0]))
    mesh.populate_bulk_data(create_edges=True)
    return mesh
