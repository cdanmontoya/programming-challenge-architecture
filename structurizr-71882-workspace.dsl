!const ORGANISATION_NAME "Screening de Usuarios"

workspace "Screening de Usuarios" "Plataforma que brinda servicios, evitando el registro de usuarios con nombres inapropiados" {

    configuration {
        scope softwaresystem
    }

    model {
        user = person "Usuario" "Usuario que navega en alguna experiencia"

        group "${ORGANISATION_NAME}" {
        
            frontend = softwareSystem "Aplicación web" "Página web con la que interactúan los usuarios de la plataforma"  "Web Browser"
            nameDatabase = softwareSystem "Base de datos de nombres" "Contiene los nombres inapropiados identificados" "Database, Existing System"
            
            service = softwareSystem "Servicio de validación de nombres" "Realiza la validación del nombre indicado contra la base de datos de nombres comprometidos" {

                backend = container "Servicio de Validación de Nombres" "Expone el servicio de validación de nombres" "Go" "Microservice" {
                    
                }
                
                cache = container "Caché" "Contiene los nombres comprometidos en un almacenamiento de baja latencia" "Redis" "Database"
                job = container "Trabajo de sincronización" "Extrae lotes de nombres comprometidos de la base de datos de nombres y los escribe en la caché" "Python"
                orchestrator = container "Orquestador" "Inicia el trabajo de sincronización de forma periódica y gestiona los errores y reintentos" "Step Functions"
                
            }
            
            user -> frontend "Usa"
            frontend -> backend "Usa"
            backend -> nameDatabase "Usa"
            

            
            backend -> cache "consulta"
            orchestrator -> job "inicia/gestiona"
            job -> cache "escribe"
            job -> nameDatabase "consulta"
            
            
            development = deploymentEnvironment "cloud" {
            deploymentNode "AWS" {
                tags "Amazon Web Services - Cloud"
                
                deploymentNode "US-East-1" {
                    tags "Amazon Web Services - Region"
                    
                    
                    autoScalingGroup = deploymentNode "Auto Scaling Group" "" "" "Infrastructure" {
                        tags "Amazon Web Services - Auto Scaling"
                        
                        deploymentNode "EC2" "" "" "Infrastructure" {
                            tags "Amazon Web Services - EC2 Instance"
                            
                            containerInstance backend
                        }
                    }
                    
                    deploymentNode "Step Functions" "" "" "Infrastructure" {
                        tags "Amazon Web Services - Step Functions"
                        containerInstance orchestrator
                    }
                    
                    deploymentNode "Glue Job" "" "" "Infrastructure" {
                        tags "Amazon Web Services - Glue"
                        containerInstance job
                    }
                    
                    deploymentNode "Elastic Cache" "" "" "Infrastructure" {
                        tags "Amazon Web Services - ElastiCache"
                        containerInstance cache
                    }
                    
                    apiGw = infrastructureNode "API Gateway" "" "" "Infrastructure" {
                        tags "Amazon Web Services - API Gateway"
                    }
                    
                    loadBalancer = infrastructureNode "Load Balancer" "" "" "Infrastructure" {
                        tags "Amazon Web Services - Elastic Load Balancing ELB Application load balancer"
                    }
                    
                    apiGw -> loadBalancer "Redirige a"
                    loadBalancer -> autoScalingGroup "Redirige a"
                    

                    
                    
                    # containerInstance backend
                    # deploymentNode "MySQL" {
                    #     containerInstance cache
                    # }
                    
                    
                    
                }
                
                
            }
        }

        
        }
    }
    
    
    views {
        systemContext service "Diagram1" {
            include *
            autolayout lr
        }
        
        container service "Diagram2" {
            include *
            # autolayout 
        }
        
        deployment * cloud {
            include *
            autoLayout lr
        }
        
        dynamic service {
            title "Poblar caché"
            orchestrator -> job "Inicializa el trabajo de extracción de nombres"
            
            job -> nameDatabase "Consulta los nombres de usuarios comprometidos"
            nameDatabase -> job "Retorna los nombres de usuarios comprometidos"
            
            job -> cache "Escribe los nombres de usuarios comprometidos"
            
            autoLayout 
        }
        
        dynamic service {
            title "Validar nombre"
            frontend -> backend "Solicita validar un nombre"
            
            backend -> cache "Consulta el nombre dentro de los nombres comprometidos"
            cache -> backend "Retorna el nombre comprometido identificado"
             
            backend -> nameDatabase "Si falla la consulta a la caché, consulta los nombres comprometidos similares"
            nameDatabase -> backend "Retorna los nombres comprometidos"
            
            backend -> frontend "Retorna si el nombre de usuario solicitado está comprometido o no"
            
            # autoLayout lr
        }
        
        
        
        
        theme https://static.structurizr.com/themes/amazon-web-services-2020.04.30/theme.json



        styles {
            element "Element" {
                background #1168bd
                color #ffffff
                shape RoundedBox
            }
        
            element "Existing System" {
                background #999999
                color #ffffff
            }
            
            element "Microservice" {
                shape Hexagon
            }

            element "Database" {
                shape Cylinder
            }

            element "File System" {
                shape "Folder"
            }

            element "Stream" {
                shape "Cylinder"
            }
            
            element "Web Browser" {
                shape WebBrowser
                background #999999
                color #ffffff
            }
            element "Mobile App" {
                shape MobileDeviceLandscape
                background #999999
                color #ffffff
            }
            
            element "Infrastructure" {
                background #ffffff
            }
        }
        
    }
    
    

}

