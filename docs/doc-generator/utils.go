package main

import (
	"bufio"
	"bytes"
	"encoding/base64"
	"errors"
	"fmt"
	"io"
	"io/ioutil"
	"os"
	"path"
	"path/filepath"
	"regexp"
	"sort"
	"strconv"
	"strings"
	"text/template"

	camel "github.com/apache/camel-k/pkg/apis/camel/v1alpha1"
	"github.com/iancoleman/strcase"
	"k8s.io/apimachinery/pkg/runtime"
	"k8s.io/apimachinery/pkg/runtime/schema"
	"k8s.io/apimachinery/pkg/runtime/serializer"
	"k8s.io/apimachinery/pkg/util/yaml"
)

var funcMap = template.FuncMap{
	"ToCamel": strcase.ToCamel,
}

func handleGeneralError(desc string, err error) {
	if err != nil {
		fmt.Printf("%s: %+v\n", desc, err)
		os.Exit(2)
	}
}

func isFile(path string) (bool, error) {
	_, err := os.Stat(path)
	if err != nil {
		return false, err
	}

	return true, nil
}

func assignFile(paths ...string) string {
	f := filepath.Join(paths...)
	if is, err := isFile(f); !is {
		handleGeneralError(fmt.Sprintf("Error: file %s cannot be found", f), err)
	}
	return f
}

func isDirectory(path string) (bool, error) {
	fileInfo, err := os.Stat(path)
	if err != nil {
		return false, err
	}
	return fileInfo.IsDir(), err
}

func assignDir(path ...string) string {
	d := filepath.Join(path...)
	if is, err := isDirectory(d); !is {
		handleGeneralError(fmt.Sprintf("Error: directory %s cannot be found", d), err)
	}

	return d
}

func loadTemplate(templateFile string, dependentTemplates ...string) *template.Template {
	templates := []string{templateFile}
	templates = append(templates, dependentTemplates...)
	t, err := template.New(filepath.Base(templateFile)).Funcs(funcMap).ParseFiles(templates...)
	handleGeneralError(fmt.Sprintf("cannot load template file from %s", templateFile), err)
	return t
}

func listKamelets(dir string, filterFilePath string) []camel.Kamelet {
	scheme := runtime.NewScheme()
	err := camel.AddToScheme(scheme)
	handleGeneralError("cannot to add camel APIs to scheme", err)

	codecs := serializer.NewCodecFactory(scheme)
	gv := camel.SchemeGroupVersion
	gvk := schema.GroupVersionKind{
		Group:   gv.Group,
		Version: gv.Version,
		Kind:    "Kamelet",
	}
	decoder := codecs.UniversalDecoder(gv)

	kamelets := make([]camel.Kamelet, 0)
	files, err := ioutil.ReadDir(dir)
	filesSorted := make([]string, 0)
	handleGeneralError(fmt.Sprintf("cannot list dir %q", dir), err)

	var requiredKamelets []string
	if len(filterFilePath) > 0 {
		filterFile, err := os.Open(filterFilePath)
		handleGeneralError(fmt.Sprintf("cannot read filter file %s", filterFilePath), err)

		scanner := bufio.NewScanner(filterFile)
		scanner.Split(bufio.ScanLines)
		for scanner.Scan() {
			requiredKamelets = append(requiredKamelets, scanner.Text())
		}
		filterFile.Close()
	}

	if len(requiredKamelets) == 0 {
		fmt.Printf("Warning: No kamelets listed in %s so including all of them", filterFilePath)
		os.Exit(1)
	}

	for _, fd := range files {
		if fd.IsDir() || !strings.HasSuffix(fd.Name(), ".kamelet.yaml") {
			continue
		}

		//
		// Filters the kamelets based on the contents of the filter file
		//
		for _, k := range requiredKamelets {
			if fmt.Sprintf("%s.kamelet.yaml", k) == fd.Name() {
				// kamelet is listed in filter file
				fullName := filepath.Join(dir, fd.Name())
				filesSorted = append(filesSorted, fullName)
				break
			}
		}
	}
	sort.Strings(filesSorted)

	for _, fileName := range filesSorted {
		content, err := ioutil.ReadFile(fileName)
		handleGeneralError(fmt.Sprintf("cannot read file %q", fileName), err)

		json, err := yaml.ToJSON(content)
		handleGeneralError(fmt.Sprintf("cannot convert file %q to JSON", fileName), err)

		kamelet := camel.Kamelet{}
		_, _, err = decoder.Decode(json, &gvk, &kamelet)
		handleGeneralError(fmt.Sprintf("cannot unmarshal file %q into Kamelet", fileName), err)
		kamelets = append(kamelets, kamelet)
	}

	fmt.Printf("Processing %d kamelets\n", len(kamelets))
	return kamelets
}

func saveImage(k camel.Kamelet, out string) string {
	if ic, ok := k.ObjectMeta.Annotations["camel.apache.org/kamelet.icon"]; ok {
		svgb64Prefix := "data:image/svg+xml;base64,"
		if strings.HasPrefix(ic, svgb64Prefix) {
			data := ic[len(svgb64Prefix):]
			decoder := base64.NewDecoder(base64.StdEncoding, strings.NewReader(data))
			iconContent, err := ioutil.ReadAll(decoder)
			handleGeneralError(fmt.Sprintf("cannot decode icon from Kamelet %s", k.Name), err)
			dest := filepath.Join(out, "assets", "images", "kamelets", fmt.Sprintf("%s.svg", k.Name))
			if _, err := os.Stat(dest); err == nil {
				err = os.Remove(dest)
				handleGeneralError(fmt.Sprintf("cannot remove file %q", dest), err)
			}
			err = ioutil.WriteFile(dest, iconContent, 0666)
			handleGeneralError(fmt.Sprintf("cannot write file %q", dest), err)
			fmt.Printf("%q written\n", dest)
			return fmt.Sprintf("image:kamelets/%s.svg[]", k.Name)
		}
	}
	return ""
}

//
// verify if the existing kamelet binding example should be automatically generated
// by checking if there is a comment marker in the first line
//
func shouldGenerateKameletBindingExample(fi string) bool {
	f, err := os.Open(fi)
	defer f.Close()
	if err != nil {
		// kamelet binding file doesn't exist so the generator can create it
		return true
	}
	r := bufio.NewReader(f)
	// read only the first line to verify if there is the comment marker
	line, _ := r.ReadString('\n')
	return !strings.Contains(line, DONT_OVERWRITE_MARKER)
}

func produceOutputFile(k camel.Kamelet, outputDir string, content string, extension string) {
	outputFile := filepath.Join(outputDir, k.Name+extension)
	if _, err := os.Stat(outputFile); err == nil {
		err = os.Remove(outputFile)
		handleGeneralError(fmt.Sprintf("cannot remove file %q", outputFile), err)
	}
	err := ioutil.WriteFile(outputFile, []byte(content), 0666)
	handleGeneralError(fmt.Sprintf("cannot write to file %q", outputFile), err)
	fmt.Printf("%q written\n", outputFile)
}

func processDocTemplate(k camel.Kamelet, baseDir string, docTemplate *template.Template, ctx *TemplateContext) {
	buffer := new(bytes.Buffer)
	err := docTemplate.Execute(buffer, &ctx)
	handleGeneralError("cannot process documentation template", err)

	outputDir := filepath.Join(baseDir, "pages")
	produceOutputFile(k, outputDir, buffer.String(), ".adoc")
}

func updateLink(k camel.Kamelet, img string, links []string) []string {
	var s string
	if len(img) > 0 {
		s = fmt.Sprintf("* xref:%s.adoc[%s %s]", k.Name, img, k.Spec.Definition.Title)
	} else {
		s = fmt.Sprintf("* xref:%s.adoc[%s]", k.Name, k.Spec.Definition.Title)
	}

	return append(links, s)
}

func processYamlTemplate(k camel.Kamelet, baseDir string, yamlTemplate *template.Template, ctx *TemplateContext) {
	buffer := new(bytes.Buffer)
	err := yamlTemplate.Execute(buffer, ctx)
	handleGeneralError("cannot process yaml binding template", err)

	produceBindingFile(k, baseDir, "camel-k", buffer.String())
}

func processCoreYamlTemplate(k camel.Kamelet, baseDir string, yamlTemplate *template.Template, ctx *TemplateContext) {
	buffer := new(bytes.Buffer)
	err := yamlTemplate.Execute(buffer, ctx)
	handleGeneralError("cannot process yaml binding template", err)

	produceBindingFile(k, baseDir, "core", buffer.String())
}

type TemplateContext struct {
	Kamelet            camel.Kamelet
	Image              string
	TemplateProperties map[string]string
}

func NewTemplateContext(kamelet camel.Kamelet, image string) TemplateContext {
	return TemplateContext{
		Kamelet:            kamelet,
		Image:              image,
		TemplateProperties: map[string]string{},
	}
}

type Prop struct {
	Name     string
	Title    string
	Required bool
	Default  *string
	Example  *string
}

func (p Prop) GetSampleValue() string {
	if p.Default != nil {
		return *p.Default
	}
	if p.Example != nil {
		return *p.Example
	}
	return fmt.Sprintf(`"The %s"`, p.Title)
}

func getSortedProps(k camel.Kamelet) []Prop {
	required := make(map[string]bool)
	props := make([]Prop, 0, len(k.Spec.Definition.Properties))
	for _, r := range k.Spec.Definition.Required {
		required[r] = true
	}
	for key := range k.Spec.Definition.Properties {
		prop := k.Spec.Definition.Properties[key]
		var def *string
		if prop.Default != nil {
			b, err := prop.Default.MarshalJSON()
			handleGeneralError(fmt.Sprintf("cannot marshal property %q default value in Kamelet %s", key, k.Name), err)
			defVal := string(b)
			def = &defVal
		}
		var ex *string
		if prop.Example != nil {
			b, err := prop.Example.MarshalJSON()
			handleGeneralError(fmt.Sprintf("cannot marshal property %q example value in Kamelet %s", key, k.Name), err)
			exVal := string(b)
			ex = &exVal
		}
		props = append(props, Prop{Name: key, Title: prop.Title, Required: required[key], Default: def, Example: ex})
	}
	sort.Slice(props, func(i, j int) bool {
		ri := props[i].Required
		rj := props[j].Required
		if ri && !rj {
			return true
		} else if !ri && rj {
			return false
		}
		return props[i].Name < props[j].Name
	})
	return props
}

func (ctx *TemplateContext) HasProperties() bool {
	return len(ctx.Kamelet.Spec.Definition.Properties) > 0
}

func (ctx *TemplateContext) HasRequiredProperties() bool {
	propDefs := getSortedProps(ctx.Kamelet)

	for _, propDef := range propDefs {
		if propDef.Required {
			return true
		}
	}

	return false
}

func (ctx *TemplateContext) PropertyList() string {
	propDefs := getSortedProps(ctx.Kamelet)

	sampleConfig := make([]string, 0)
	for _, propDef := range propDefs {
		if !propDef.Required {
			continue
		}
		key := propDef.Name
		if propDef.Default == nil {
			ex := propDef.GetSampleValue()
			sampleConfig = append(sampleConfig, fmt.Sprintf("%s: %s", key, ex))
		}
	}

	/*
		Creates the properties list in the YAML format.
	*/
	props := ""
	if len(sampleConfig) > 0 {
		props = fmt.Sprintf("\n    %s:\n      %s", "properties", strings.Join(sampleConfig, "\n      "))
	}

	return props
}

func (ctx *TemplateContext) ParameterList() string {
	tp := ctx.Kamelet.ObjectMeta.Labels["camel.apache.org/kamelet.type"]
	propDefs := getSortedProps(ctx.Kamelet)

	sampleConfig := make([]string, 0)
	for _, propDef := range propDefs {
		if !propDef.Required {
			continue
		}
		key := propDef.Name
		if propDef.Default == nil {
			ex := propDef.GetSampleValue()
			sampleConfig = append(sampleConfig, fmt.Sprintf("%s: %s", key, ex))
		}
	}

	props := ""

	if len(sampleConfig) > 0 {
		paddingSpace := ""
		switch tp {
		case "sink":
			props = fmt.Sprintf("\n%10s%s:\n%12s%s", "", "parameters",
				"", strings.Join(sampleConfig, fmt.Sprintf("\n%12s", "")))
		case "source":
			props = fmt.Sprintf("\n%6s%s:\n%8s%s", "", "parameters",
				"", strings.Join(sampleConfig, fmt.Sprintf("\n%8s", "")))
		case "action":
			props = fmt.Sprintf("\n%10s%s:\n%12s%s", paddingSpace, "parameters",
				"", strings.Join(sampleConfig, fmt.Sprintf("\n%8s", "")))
		}
	}

	return props
}

func (ctx *TemplateContext) SetVal(key, val string) string {
	ctx.TemplateProperties[key] = val
	return ""
}

func (ctx *TemplateContext) GetVal(key string) string {
	return ctx.TemplateProperties[key]
}

func (ctx *TemplateContext) Properties() string {
	content := ""
	if len(ctx.Kamelet.Spec.Definition.Properties) > 0 {
		props := getSortedProps(ctx.Kamelet)
		content += `[width="100%",cols="2,^2,3,^2,^2,^3",options="header"]` + "\n"
		content += "|===\n"
		content += tableLine("Property", "Name", "Description", "Type", "Default", "Example")

		for _, propDef := range props {
			key := propDef.Name
			prop := ctx.Kamelet.Spec.Definition.Properties[key]
			name := key
			if propDef.Required {
				name = "*" + name + " {empty}* *"
			}
			var def string
			if propDef.Default != nil {
				def = "`" + strings.ReplaceAll(*propDef.Default, "`", "'") + "`"
			}
			var ex string
			if propDef.Example != nil {
				ex = "`" + strings.ReplaceAll(*propDef.Example, "`", "'") + "`"
			}
			content += tableLine(name, prop.Title, prop.Description, prop.Type, def, ex)
		}

		content += "|===\n"

	}
	return content
}

func (ctx *TemplateContext) ExampleKamelBindCommand(ref string) string {
	if generate, _ := strconv.ParseBool(ctx.GetVal("GenerateExampleBinding")); generate {
		tp := ctx.Kamelet.ObjectMeta.Labels["camel.apache.org/kamelet.type"]
		var prefix string
		switch tp {
		case "source":
			prefix = "source."
		case "sink":
			prefix = "sink."
		case "action":
			prefix = "step-0."
		default:
			handleGeneralError("unknown kamelet type", errors.New(tp))
		}

		cmd := "kamel bind "
		timer := "timer-source?message=Hello"
		kamelet := ctx.Kamelet.Name
		propDefs := getSortedProps(ctx.Kamelet)
		for _, p := range propDefs {
			if p.Required && p.Default == nil {
				val := p.GetSampleValue()
				if strings.HasPrefix(val, `"`) {
					kamelet += fmt.Sprintf(` -p "%s%s=%s`, prefix, p.Name, val[1:])
				} else {
					kamelet += fmt.Sprintf(" -p %s%s=%s", prefix, p.Name, val)
				}
			}
		}

		switch tp {
		case "source":
			return cmd + kamelet + " " + ref
		case "sink":
			return cmd + ref + " " + kamelet
		case "action":
			return cmd + timer + " --step " + kamelet + " " + ref
		default:
			handleGeneralError("unknown kamelet type", errors.New(tp))
		}
		return ""
	} else {
		return ctx.ReadKamelBindExample(ctx.Kamelet.Name, ref)
	}
}

func (ctx *TemplateContext) GenerateExampleBinding() bool {
	return generateExampleBinding
}

// this is called from KameletTemplate to source the kamelet binding example from a file
// skip the first line and replace the sink kind when the kind is a knative channel
func (ctx *TemplateContext) ReadKameletBindingExample(kameletName string) string {
	f := path.Join(projectBaseDir, "templates/bindings/camel-k/", kameletName+"-binding.yaml")
	file, _ := os.Open(f)
	defer file.Close()
	// skip the first line, as it contains the comment marker
	line, _ := bufio.NewReader(file).ReadSlice('\n')
	_, _ = file.Seek(int64(len(line)), io.SeekStart)
	r := bufio.NewReader(file)
	contentBytes, _ := ioutil.ReadAll(r)
	content := string(contentBytes)

	// KameletTemplate may set the sink to a Channel, so this condition replaces the sink to a knative channel
	if ctx.GetVal("RefKind") != "KafkaTopic" {
		var re = regexp.MustCompile(`(  sink:\n\s*ref:\n)(\s*kind:)(.*)(\n\s*apiVersion:)(.*)(\n\s*name:)(.*)`)
		content = re.ReplaceAllString(content, fmt.Sprintf(`$1$2 %s$4 %s$6 %s`, ctx.GetVal("RefKind"), ctx.GetVal("RefApiVersion"), ctx.GetVal("RefName")))
	}
	return content
}

// this is called from KameletTemplate to source the "kamel bind" command example from the kamelet binding example file
// replace the sink kind when the kind is a knative channel
func (ctx *TemplateContext) ReadKamelBindExample(kameletName string, ref string) string {
	f := path.Join(projectBaseDir, "templates/bindings/camel-k/", kameletName+"-binding.yaml")
	file, _ := os.Open(f)
	defer file.Close()
	// skip the first line, as it contains the comment marker
	line, _ := bufio.NewReader(file).ReadSlice('\n')
	content := string(line)
	content = strings.ReplaceAll(content, "log:info", ref)
	content = strings.ReplaceAll(content, "# ", "")
	return content
}

func saveNav(links []string, out string) {
	content := "// THIS FILE IS AUTOMATICALLY GENERATED: DO NOT EDIT\n"
	for _, l := range links {
		content += l + "\n"
	}
	content += "// THIS FILE IS AUTOMATICALLY GENERATED: DO NOT EDIT\n"
	dest := filepath.Join(out, "nav.adoc")
	if _, err := os.Stat(dest); err == nil {
		err = os.Remove(dest)
		handleGeneralError(fmt.Sprintf("cannot remove file %q", dest), err)
	}
	err := ioutil.WriteFile(dest, []byte(content), 0666)
	handleGeneralError(fmt.Sprintf("cannot write file %q", dest), err)
	fmt.Printf("%q written\n", dest)
}

func produceBindingFile(k camel.Kamelet, baseDir string, projectName string, content string) {
	camelKOutputDir := filepath.Join(baseDir, "templates", "bindings", projectName)

	produceOutputFile(k, camelKOutputDir, content, "-binding.yaml")
}

func tableLine(val ...string) string {
	res := ""
	for _, s := range val {
		clean := strings.ReplaceAll(s, "|", "\\|")
		res += "| " + clean
	}
	return res + "\n"
}
