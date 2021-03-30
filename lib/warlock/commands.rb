
require "warlock/iar_project"

module Warlock
    class Commands
        def add_src(file_name)
            root_directory = __dir__
            fileFromParameters = args[:filename].to_s
            fileToAdd = file_name
            maxClosenessLevel = 0
            bestProjectToAdd = ''
            bestProjectToAddRef = nil
            iarProjects = Array.new()
            # find required file first
            Dir[root_directory + "/**/#{fileFromParameters}"].each do |f|
                fileToAdd = f 
            end 
            if fileToAdd == ''
                puts 'No such file'
                exit(-1)
            end              
            # find all project files and process them
            Dir[root_directory + "/**/*.ewp"].each do |s| 
                
                p = IarProject.new(filepath: s) 
                iarProjects.push(p)
                closenessLevel = p.calculate_closeness_level(referencefile: fileToAdd)

                if closenessLevel > maxClosenessLevel
                    maxClosenessLevel = closenessLevel
                    bestProjectToAdd = s
                    bestProjectToAddRef = p
                end
            end

            puts maxClosenessLevel.to_s + ' : ' + bestProjectToAdd

            bestProjectToAddRef.add_source_file(referencefile: fileToAdd, expectedclosenesslevel: maxClosenessLevel)
        end
    end
end