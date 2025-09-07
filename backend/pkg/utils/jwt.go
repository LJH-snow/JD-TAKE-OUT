package utils

import (
	"errors"
	"time"

	"github.com/golang-jwt/jwt/v5"
)

// Claims JWT声明
type Claims struct {
	UserID   uint   `json:"user_id"`
	Username string `json:"username"`
	Role     string `json:"role"` // user, admin
	jwt.RegisteredClaims
}

// JWTUtil JWT工具类
type JWTUtil struct {
	secretKey []byte
	expire    time.Duration
}

// NewJWTUtil 创建JWT工具实例
func NewJWTUtil(secretKey string, expireHours int) *JWTUtil {
	return &JWTUtil{
		secretKey: []byte(secretKey),
		expire:    time.Duration(expireHours) * time.Hour,
	}
}

// GenerateToken 生成Token
func (j *JWTUtil) GenerateToken(userID uint, username, role string) (string, error) {
	claims := Claims{
		UserID:   userID,
		Username: username,
		Role:     role,
		RegisteredClaims: jwt.RegisteredClaims{
			ExpiresAt: jwt.NewNumericDate(time.Now().Add(j.expire)),
			IssuedAt:  jwt.NewNumericDate(time.Now()),
			NotBefore: jwt.NewNumericDate(time.Now()),
		},
	}

	token := jwt.NewWithClaims(jwt.SigningMethodHS256, claims)
	return token.SignedString(j.secretKey)
}

// ParseToken 解析Token
func (j *JWTUtil) ParseToken(tokenString string) (*Claims, error) {
	token, err := jwt.ParseWithClaims(tokenString, &Claims{}, func(token *jwt.Token) (interface{}, error) {
		return j.secretKey, nil
	})

	if err != nil {
		return nil, err
	}

	if claims, ok := token.Claims.(*Claims); ok && token.Valid {
		return claims, nil
	}

	return nil, errors.New("invalid token")
}

// RefreshToken 刷新Token
func (j *JWTUtil) RefreshToken(tokenString string) (string, error) {
	claims, err := j.ParseToken(tokenString)
	if err != nil {
		return "", err
	}

	// 如果Token还有超过30分钟才过期，则不需要刷新
	if time.Until(claims.ExpiresAt.Time) > 30*time.Minute {
		return tokenString, nil
	}

	// 生成新Token
	return j.GenerateToken(claims.UserID, claims.Username, claims.Role)
}
