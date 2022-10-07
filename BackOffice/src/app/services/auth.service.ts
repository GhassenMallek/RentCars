import { Injectable } from '@angular/core';
import { HttpClient, HttpHeaders } from '@angular/common/http';
import { Observable } from 'rxjs';

const AUTH_API = 'http://localhost:3000/admin';

const httpOptions = {
  headers: new HttpHeaders({ 'Content-Type': 'application/json' })
};

@Injectable({
  providedIn: 'root',
})
export class AuthService {
  constructor(private http: HttpClient) { }

  login(email: string, password: string): Observable<any> {
    return this.http.post(
      AUTH_API + '/login',
      {
        email,
        password,
      },
      httpOptions
    );
  }

  register(fullname: string, email: string, password: string, phoneMobile: number, phoneFixe: number, address: string, website: string, role: string): Observable<any> {
    return this.http.post(
      AUTH_API + '/',
      {
        fullname,
        email,
        password,
        phoneMobile,
        phoneFixe,
        address,
        website,
        role
      },
      httpOptions
    );
  }

  logout(): Observable<any> {
    return this.http.post(AUTH_API + 'signout', {}, httpOptions);
  }
}
