package main

import (
	"fmt"
	"os"
	"strconv"
)

// marker added to the first line of kamelet binding files in templates/bindings/camel-k directory
// generator will not generate a kamelet binding example and will source this kamelet binding file into the generated doc
// if the developer provides a kamelet binding file, a "kamel bind" example command must also be provided as a comment in the first line
const DONT_OVERWRITE_MARKER = "kamel bind"

const (
	modulesRoot            = "modules/ROOT"
	exampleTemplates       = "examples/template"
	templatesBindings      = "templates/bindings"
	kameletTemplate        = "kamelet.adoc.tmpl"
	kameletBindingTemplate = "kamelet-binding-sink-source.tmpl"
	propertiesListTemplate = "properties-list.tmpl"
)

var generateExampleBinding bool
var projectBaseDir string

func main() {

	if len(os.Args) != 2 {
		println("usage: <generator directory> <base project directory>")
		os.Exit(1)
	}

	projectBaseDir = assignDir(os.Args[1])
	docBaseDir := assignDir(projectBaseDir, "docs")
	kameletsDir := assignDir(projectBaseDir, "kamelets")
	modulesRootDir := assignDir(docBaseDir, modulesRoot)

	filterFile := assignFile(projectBaseDir, "product-kamelets.txt")
	templateFile := assignFile(modulesRootDir, exampleTemplates, kameletTemplate)
	kameletBindingFile := assignFile(modulesRootDir, exampleTemplates, kameletBindingTemplate)
	propertiesListFile := assignFile(modulesRootDir, exampleTemplates, propertiesListTemplate)
	docTemplate := loadTemplate(templateFile, kameletBindingFile, propertiesListFile)

	//
	// Disable generation of binding examples
	//
	// camelKYamlBindingsBaseDir := assignDir(projectBaseDir, templatesBindings, "camel-k")
	// coreYamlBindingsBaseDir := assignDir(projectBaseDir, templatesBindings, "core")
	// yamlTemplateFile := assignFile(camelKYamlBindingsBaseDir, "kamelet.yaml.tmpl")
	// coreYamlTemplateFile := assignFile(coreYamlBindingsBaseDir, "kamelet-core-binding.yaml.tmpl")
	// parameterListFile := assignFile(coreYamlBindingsBaseDir, "parameter-list.tmpl")
	// yamlTemplate := loadTemplate(yamlTemplateFile, kameletBindingFile, propertiesListFile)
	// coreYamlTemplate := loadTemplate(coreYamlTemplateFile, kameletBindingFile, parameterListFile)

	kamelets := listKamelets(kameletsDir, filterFile)
	if len(kamelets) == 0 {
		fmt.Println("Error: No kamelets found. Nothing to do.")
		os.Exit(1)
	}

	links := make([]string, 0)
	for _, k := range kamelets {
		// The adoc ocumentation does not need svg images
		// img := saveImage(k, docBaseDir)

		ctx := NewTemplateContext(k, "")

		//
		// Disable generation of binding examples
		//
		// check if the kamelet binding example should be generated
		// bindingFile := path.Join(projectBaseDir, templatesBindings, "camel-k", k.Name+"-binding.yaml")
		// generateExampleBinding = shouldGenerateKameletBindingExample(bindingFile)
		generateExampleBinding := false
		ctx.SetVal("GenerateExampleBinding", strconv.FormatBool(generateExampleBinding))

		processDocTemplate(k, modulesRootDir, docTemplate, &ctx)
		links = updateLink(k, ctx.Image, links)

		//
		// Binding examples are already passed down from upstream so no need to re-create
		//
		// if generateExampleBinding {
		// 	processYamlTemplate(k, projectBaseDir, yamlTemplate, &ctx)
		// 	processCoreYamlTemplate(k, projectBaseDir, coreYamlTemplate, &ctx)
		// }
	}

	saveNav(links, modulesRootDir)
}
