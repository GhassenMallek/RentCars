import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';

@Injectable({
  providedIn: 'root'
})
export class MedecinesService {
  readonly API_URL = 'http://localhost:3000/medecines';

  constructor(private httpClient: HttpClient) { }

  getAllMedecinesn(){
    return this.httpClient.get(`${this.API_URL}/`)
  }
}