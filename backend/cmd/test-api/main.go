package main

import (
	"bytes"
	"encoding/json"
	"fmt"
	"net/http"
	"time"
)

type LoginRequest struct {
	Username string `json:"username"`
	Password string `json:"password"`
	UserType string `json:"user_type"`
}

type LoginResponse struct {
	Code    int         `json:"code"`
	Message string      `json:"message"`
	Data    interface{} `json:"data"`
}

func main() {
	// 测试健康检查接口
	fmt.Println("=== 测试健康检查接口 ===")
	resp, err := http.Get("http://localhost:8090/health")
	if err != nil {
		fmt.Printf("健康检查请求失败: %v\n", err)
		return
	}
	defer resp.Body.Close()
	fmt.Printf("健康检查响应状态: %s\n", resp.Status)

	// 测试登录接口
	fmt.Println("\n=== 测试登录接口 ===")
	loginData := LoginRequest{
		Username: "admin",
		Password: "admin123",
		UserType: "admin",
	}

	jsonData, err := json.Marshal(loginData)
	if err != nil {
		fmt.Printf("JSON序列化失败: %v\n", err)
		return
	}

	client := &http.Client{Timeout: 10 * time.Second}
	req, err := http.NewRequest("POST", "http://localhost:8090/api/v1/auth/login", bytes.NewBuffer(jsonData))
	if err != nil {
		fmt.Printf("创建请求失败: %v\n", err)
		return
	}

	req.Header.Set("Content-Type", "application/json")

	resp, err = client.Do(req)
	if err != nil {
		fmt.Printf("登录请求失败: %v\n", err)
		return
	}
	defer resp.Body.Close()

	fmt.Printf("登录响应状态: %s\n", resp.Status)

	// 解析响应
	var loginResp LoginResponse
	if err := json.NewDecoder(resp.Body).Decode(&loginResp); err != nil {
		fmt.Printf("解析响应失败: %v\n", err)
		return
	}

	fmt.Printf("登录响应数据: %+v\n", loginResp)
}
