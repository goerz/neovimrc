# Load LanguageServer.jl:
# Attempt to load from ~/.julia/environments/nvim-lspconfig
# with the regular load path as a fallback
ls_install_path = joinpath(
  get(DEPOT_PATH, 1, joinpath(homedir(), ".julia")),
  "environments",
  "nvim-lspconfig"
)
if isdir(ls_install_path)
    pushfirst!(LOAD_PATH, ls_install_path)
else
    @warn "The LS install path $ls_install_path does not exist"
end


using LanguageServer

isdir(ls_install_path) && popfirst!(LOAD_PATH)

depot_path = get(ENV, "JULIA_DEPOT_PATH", "")


function is_instantiated(path; project_filename="Project.toml")
    if isdir(path)
        if project_filename == "JuliaProject.toml"
            return isfile(joinpath(path, "JuliaManifest.toml"))
        else
            return isfile(joinpath(path, "Manifest.toml"))
        end
    elseif isfile(path)
        return is_instantiated(dirname(path); project_filename=basename(path))
    else
        return false
    end
end


function get_project_path()

    # Step 1: Tries an explicit project set by JULIA_PROJECT
    julia_project = get(ENV, "JULIA_PROJECT", nothing)
    if julia_project !== nothing && !isempty(julia_project)
        path = Base.load_path_expand(julia_project)
        if isfile(path)
            path = dirname(path)
        end
        return path
    end

    # Step 2: Look for a Project.toml file in the current working directory and
    # up. If available, prefer environments in a `test` subfolder.
    project_toml = Base.current_project()
    project_folder = dirname(project_toml)
    if project_toml !== nothing
        # A test environment takes precedent over the main project environment
        test_folder = joinpath(project_folder, "test")
        if is_instantiated(test_folder)
            return test_folder
        else
            if is_instantiated(project_toml)
                return project_folder
            else
                @warn "Project folder $project_folder is not instantiated"
            end
        end
    end

    # Step 3 (fallback): First entry in the load path
    first_load_path = get(Base.load_path(), 1, nothing)
    if first_load_path !== nothing
        if isfile(first_load_path)
            return dirname(first_load_path)
        else
            return first_load_path
        end
    end

end

project_path = get_project_path()
@info "Running language server" VERSION pwd() project_path depot_path
server = LanguageServer.LanguageServerInstance(
    stdin, stdout, project_path, depot_path
)
server.runlinter = true
run(server)
