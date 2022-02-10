module github.com/apache/camel-kamelets/docs/generator

go 1.15

require (
	github.com/apache/camel-k v1.6.0
	github.com/apache/camel-k/pkg/apis/camel v1.6.0
	github.com/bbalet/stopwords v1.0.0
	github.com/pkg/errors v0.9.1
	gopkg.in/yaml.v3 v3.0.0-20210107192922-496545a6307b
	k8s.io/apimachinery v0.21.4
	k8s.io/client-go v12.0.0+incompatible // indirect
)

replace (
	k8s.io/api => k8s.io/api v0.19.8
	k8s.io/apimachinery => k8s.io/apimachinery v0.19.8
	k8s.io/client-go => k8s.io/client-go v0.19.8
)
