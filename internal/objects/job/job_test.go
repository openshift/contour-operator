// Copyright Project Contour Authors
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

package job

import (
	"fmt"
	"testing"

	apiequality "k8s.io/apimachinery/pkg/api/equality"
	"k8s.io/utils/pointer"

	operatorv1alpha1 "github.com/projectcontour/contour-operator/api/v1alpha1"
	"github.com/projectcontour/contour-operator/internal/objects"
	objcontour "github.com/projectcontour/contour-operator/internal/objects/contour"
	operatorconfig "github.com/projectcontour/contour-operator/internal/operator/config"

	batchv1 "k8s.io/api/batch/v1"
	corev1 "k8s.io/api/core/v1"
)

func checkJobHasEnvVar(t *testing.T, job *batchv1.Job, name string) {
	t.Helper()

	for _, envVar := range job.Spec.Template.Spec.Containers[0].Env {
		if envVar.Name == name {
			return
		}
	}
	t.Errorf("job is missing environment variable %q", name)
}

func checkJobHasContainer(t *testing.T, job *batchv1.Job, name string) *corev1.Container {
	t.Helper()

	for _, container := range job.Spec.Template.Spec.Containers {
		if container.Name == name {
			return &container
		}
	}
	t.Errorf("job is missing container %q", name)
	return nil
}

func checkContainerHasImage(t *testing.T, container *corev1.Container, image string) {
	t.Helper()

	if container.Image == image {
		return
	}
	t.Errorf("container is missing image %q", image)
}

func TestDesiredJob(t *testing.T) {
	name := "job-test"
	cfg := objcontour.Config{
		Name:        name,
		Namespace:   fmt.Sprintf("%s-ns", name),
		SpecNs:      "projectcontour",
		RemoveNs:    false,
		NetworkType: operatorv1alpha1.LoadBalancerServicePublishingType,
	}
	cntr := objcontour.New(cfg)
	job := DesiredJob(cntr, operatorconfig.DefaultContourImage)
	container := checkJobHasContainer(t, job, jobContainerName)
	checkContainerHasImage(t, container, operatorconfig.DefaultContourImage)
	checkJobHasEnvVar(t, job, jobNsEnvVar)
}

func checkJobSecurityContext(t *testing.T, job *batchv1.Job, expected *corev1.PodSecurityContext) {
	t.Helper()
	if apiequality.Semantic.DeepEqual(job.Spec.Template.Spec.SecurityContext, expected) {
		return
	}
	t.Errorf("deployment has unexpected security context %#v instead of %#v", job.Spec.Template.Spec.SecurityContext, expected)
}

func TestSecurityContextJob(t *testing.T) {

	name := "security-context-test"
	sc := &corev1.PodSecurityContext{
		RunAsUser: pointer.Int64(int64(0)),
	}
	cfg := objcontour.Config{
		Name:        name,
		Namespace:   fmt.Sprintf("%s-ns", name),
		SpecNs:      "projectcontour",
		RemoveNs:    false,
		NetworkType: operatorv1alpha1.LoadBalancerServicePublishingType,
	}
	cntr := objcontour.New(cfg)
	cntr.Spec.ContourSecurityContext = sc

	job := DesiredJob(cntr, "test-image")
	checkJobSecurityContext(t, job, sc)
}

func TestDefaultSecurityContextJob(t *testing.T) {
	name := "security-context-test"
	cfg := objcontour.Config{
		Name:        name,
		Namespace:   fmt.Sprintf("%s-ns", name),
		SpecNs:      "projectcontour",
		RemoveNs:    false,
		NetworkType: operatorv1alpha1.LoadBalancerServicePublishingType,
	}
	cntr := objcontour.New(cfg)

	job := DesiredJob(cntr, "test-image")
	checkJobSecurityContext(t, job, objects.NewUnprivilegedPodSecurity())
}
