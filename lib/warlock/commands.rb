
require "warlock/iar_project"

module Warlock
    class Commands
        def add_src(file_name)
            root_directory = Pathname.new(Dir.pwd).cleanpath.to_s
            file_name = file_name.to_s
            puts ''
            puts 'The root directory for process is: ' + root_directory
            puts 'File to add: ' + file_name
            fileToAdd = ''
            maxClosenessLevel = 0
            bestProjectToAdd = ''
            bestProjectToAddRef = nil
            iarProjects = Array.new()
            # find required file first
            Dir[root_directory + "/**/#{file_name}"].each do |f|
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

            bestProjectToAddRef.add_source_file(referencefile: fileToAdd, expectedclosenesslevel: maxClosenessLevel)

            puts 'Added to : ' + bestProjectToAdd 
            puts 'Closeness level : ' + maxClosenessLevel.to_s
        end
    end
end