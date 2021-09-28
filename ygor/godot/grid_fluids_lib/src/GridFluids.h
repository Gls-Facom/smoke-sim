#ifndef _GRID_FLUIDS_H
#define _GRID_FLUIDS_H

#include <Godot.hpp>
#include <Node2D.hpp>
#include <vector>
#include <algorithm>
#include <iostream>


using namespace std;
using namespace godot;

class Vect{
public:
    double pressure;
    double density;
    Vector2 pos;
    Vector2 vel;
};


class GridFluids: public Node2D 
{
    GODOT_CLASS(GridFluids, Node2D);

    // Exposed props
    double maxSpeed = 1000.0;
    int maxIterPoisson = 20;
    int subSteps = 10;
    double rho_const = 1.0;
    double diff_const = 0.0;
    double force_const = 2.0;
    double source_const = 2.0;
    Vector2 tile_size = Vector2(1, 1);
    Vector2 grid_size = Vector2(800, 800);
    Vector2 vector_size = Vector2(0, 0);
    Vector2 mouse_pos = Vector2(1, 1);
    Vector2 prev_mouse_pos = Vector2(-1, -1);
    Vector2 source_pos = Vector2(-1,-1);

public:
    static void _register_methods();
    void _init();

    // Functions 
    double update_field(double delta, Array grid, Vector2 externalForces);
    void update_grid(vector<vector<Vect>> &vectors, Array grid);
    void project(vector<vector<Vect>> &vectors);
    void diffuse(vector<vector<Vect>> &vectors, double delta, double diff);
    Vector2 gradient_at_point(int x, int y, vector<vector<tuple<double,double,double,double>>> &grid);
    vector<vector<Vector2>> gradient(vector<vector<tuple<double,double,double,double>>> &grid);
    double divergent_at_point(int x, int y, vector<vector<Vect>> &vectors);
    vector<vector<double>> divergent(vector<vector<Vect>> &vectors);
    void poisson_solver(vector<vector<double>> &div, vector<vector<tuple<double,double,double,double>>> &x0, double tol);
    void advect(vector<vector<Vect>> &vectors, double timestep);
    void add_force(vector<vector<Vect>> &vectors, double delta, Vector2 force);
    void update_boundary(vector<vector<Vect>> &vectors);
    Vector2 bilinear_interpolation(vector<vector<Vect>> &vectors, Vector2 pos, bool pressure);
    Vector2 bilinear_interpolation_grid(Array grid, Vector2 pos, bool pressure);
    Vector2 get_minmax_velocity(Array grid);
    Vector2 get_minmax_pressure(Array grid);
    void update_particles(Array grid, Array particles, double delta);
    double check_divfree(vector<vector<Vect>>& vectors);
    Vector2 mouse_repellent(int i, int j, Vector2 pos, Vector2 vel);
    Vector2 buoyancy(int i, int j);
    void get_prev_grid(vector<vector<Vect>> &vectors, vector<vector<tuple<double,double,double,double>>> &x0);
    Array get_density_primitive_vertex(Array);
    Array get_density_primitive_colors(Array);
    Array get_density_primitive(Array);
    double get_source(int i, int j, double delta, Vector2 pos, double density);
};

#endif